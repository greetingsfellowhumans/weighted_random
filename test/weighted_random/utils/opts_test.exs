defmodule WeightedRandom.Utils.OptsTest do
  use ExUnit.Case
  alias WeightedRandom.Utils.Opts, as: Mod

  

  describe "Opts Utils" do
    test "Sanitize" do
      schema = NimbleOptions.new!([
        foo: [default: true, type: :boolean],
        bar: [required: true, type: :boolean],
      ])

      opts = [bar: true, baz: true]
      opts = Mod.sanitize(opts, schema)
      assert opts == [bar: true]
    end
  end


end
