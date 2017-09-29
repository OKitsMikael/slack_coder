defmodule SlackCoder.BuildSystem.LogParser do
  @moduledoc """
  Handles parsing of log files and returning a `SlackCoder.BuildSystem.Job` struct
  """
  use PatternTap
  alias SlackCoder.BuildSystem.{Job, Job.Test, Job.Test.File}

  @supported_systems ~w(rspec cucumber)a
  def parse(body) do
    results = filter_log(body)

    tests = for system <- @supported_systems do
              apply(__MODULE__, :"test_for_#{system}", [results])
            end
    %Job{
      tests: Enum.reject(tests, &match?(%Test{files: []}, &1))
    }
  end

  def flatten(%File{} = file), do: [file]
  def flatten([%File{} | _] = files), do: files
  def flatten(%Job{} = job), do: flatten([job])
  def flatten([%Job{} | _]= jobs) do
    for job <- jobs, test <- job.tests, file <- test.files do
      %File{id: job.id, type: test.type, seed: test.seed, file: file, system: job.system, failure_log_id: job.failure_log_id}
    end
    |> Enum.uniq()
  end

  def test_for_rspec(results) do
    %Test{
      type: :rspec,
      seed: find_rspec_seed(results),
      files: find_rspec_failures(results)
    }
  end

  def test_for_cucumber(results) do
    %Test{
      type: :cucumber,
      files: find_cucumber_failures(results)
    }
  end

  @seed_regex ~r/Randomized with seed (?<seed>\d+)/
  defp find_rspec_seed(results) do
    results
    |> Enum.filter(&match?("Randomized with seed" <> _, &1))
    |> List.first()
    |> case do
      s when is_binary(s) ->
        seed = Regex.named_captures(@seed_regex, s)["seed"]
        {seed, _} = Integer.parse(seed)
        seed
      _ -> nil
    end
  end

  @file_line_matcher ~r/(?<file>.+[^\[\d])(?<line>:\d+|\[.+\])/
  for type <- ~w(rspec cucumber)a do
    defp unquote(:"find_#{type}_failures")(results) do
      results
      |> Stream.map(&Regex.named_captures(~r/#{unquote(type)} #{@file_line_matcher.source}.*?# (?<description>.*)/, &1))
      |> Stream.filter(&(&1))
      |> Enum.map(&({Map.fetch!(&1, "file"), fix_line(Map.fetch!(&1, "line")), Map.fetch!(&1, "description")}))
    end
  end

  defp fix_line(":" <> line), do: line
  defp fix_line(line), do: line

  @line_separator if(Mix.env == :test, do: "\n", else: "\r\n")
  def filter_log(body) when is_binary(body) do
    body
    |> String.split(@line_separator)
    |> Stream.filter(&keep?/1)
    |> Enum.map(&remove_colors/1)
  end

  defp keep?("Randomized with seed" <> _), do: true
  defp keep?(unquote(IO.ANSI.red) <> "rspec ./spec" <> _), do: true
  defp keep?("rspec ./spec" <> _), do: true
  defp keep?(unquote(IO.ANSI.red) <> "cucumber features/" <> _), do: true
  defp keep?("cucumber features/" <> _), do: true
  defp keep?(_line), do: false

  defp remove_colors(text), do: String.replace(text, ~r/\e\[.+?m/, "")
end
