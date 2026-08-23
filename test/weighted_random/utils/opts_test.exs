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
    test "Merge" do
      schema1 = NimbleOptions.new!([
        foo: [default: true, type: :boolean],
        bar: [required: true, type: :boolean],
      ])
      schema2 = NimbleOptions.new!([
        baz: [default: 123, type: :integer],
      ])

      opts = Mod.merge([schema1, schema2])
      assert is_struct(opts, NimbleOptions)
      {:ok, o} = NimbleOptions.validate([bar: false], opts)
      assert o[:foo]
      refute o[:bar]
      assert o[:baz] == 123
    end
  end

  describe "WeightedRandom opts and docs" do
    test "backend is optional in docs" do
      opts = WeightedRandom.Input.Opts.rand_schema()
      assert opts.schema[:backend][:required] == true

      opts = WeightedRandom.Input.Opts.rand_docs()
      assert opts.schema[:backend][:required] == false
    end
  end


end
