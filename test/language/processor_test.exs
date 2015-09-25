defmodule SlackCoder.Language.ProcessorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect
  alias SlackCoder.Language.Processor

  describe "keywords" do

    defmodule P1 do
      use Processor
      keyword :hello
    end

    it "finds known keywords" do
      expect P1.find_keywords("hello how are you") |> to_eq(["hello"])
    end

  end

end
