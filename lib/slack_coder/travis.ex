defmodule SlackCoder.Travis do
  alias SlackCoder.Travis.Build
  alias SlackCoder.Travis.Job
  require Logger

  def build_info(owner, repo, build) do
    "/repos/#{owner}/#{repo}/builds/#{build}"
    |> Build.get()
    |> handle_build_fetch()
    |> Map.get(:body, [])
  end

  defp handle_build_fetch({:ok, %HTTPoison.Response{status_code: 200} = response}) do
    response
  end
  defp handle_build_fetch({ok_or_error, problem}) when ok_or_error in ~w(ok error)a do
    Logger.warn """
    #{__MODULE__} job build fetch failed

    #{inspect problem}
    """
    %{body: []} # Return nothing
  end

  def job_log(%Build{id: id}) do
    "/jobs/#{id}/log"
    |> Job.get()
    |> handle_job_fetch()
  end

  defp handle_job_fetch({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    body
    |> Job.filter_log()
    |> Job.new()
  end
  # Cannot use follow_redirect: true, cause need to drop authorization header
  defp handle_job_fetch({:ok, %HTTPoison.Response{status_code: 307, headers: headers}}) do
    {"Location", redirect} = Enum.find(headers, &(match?({"Location", _}, &1)))
    redirect
    |> HTTPoison.get()
    |> handle_job_fetch()
  end
  defp handle_job_fetch({ok_or_error, response}) when ok_or_error in ~w(ok error)a do
    Logger.warn """
    #{__MODULE__} job log fetch failed

    #{inspect response}
    """
    Job.new([])
  end

end
