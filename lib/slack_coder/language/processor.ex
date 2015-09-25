defmodule SlackCoder.Language.Processor do

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :keywords, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro keyword(keyword) when is_atom(keyword), do: quote(do: @keyword unquote(to_string(keyword)))
  defmacro keyword(keyword) when is_binary(keyword), do: quote(do: @keyword unquote(keyword))

  defmacro __before_compile__(env) do
    keywords = Module.get_attribute(env.module, :keywords)
    quote do
      def find_keywords(keywords), do: process_keywords(keywords, [])
      defp process_keywords(keywords, _) when is_binary(keywords), do: process_keywords(String.split(keywords, " "), [])
      defp process_keywords([], keywords), do: keywords
      defp process_keywords([keyword | candidates], keywords) when keyword in unquote(keywords),
        do: process_keywords(candidates, [keyword | keywords])
      defp process_keywords([_keyword | candidates], keywords), do: process_keywords(candidates, keywords)
    end
  end

end
