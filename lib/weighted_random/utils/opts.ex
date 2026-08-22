defmodule WeightedRandom.Utils.Opts do
  @moduledoc false

  #@default_backend WeightedRandom.Backend.WalkerAlias

  #@config_opts [
  #  backend: %{
  #    doc: "The module implementing a weighted randomness algorithm", 
  #    default: @default_backend, 
  #    allow_nil: false,
  #    one_of: [
  #      WeightedRandom.Backend.WalkerAlias,
  #      WeightedRandom.Backend.Linear,
  #  ]},
  #  index: %{
  #    doc: "Whether the `:target` points at an index of the outcomes (if `true`), or at the actual value of one of the outcomes (if `false`)",
  #    default: true,
  #    allow_nil: false,
  #    one_of: [true, false]
  #  },
  #  probability_type: %{
  #    doc: "Only used by the backend module. To avoid floating point precision issues, you can use :fraction so that the probabilities are all tuples of `{numenator :: integer(), denominator :: integer()}` In which they all have the same denominator which equals the sum of all numinators.",
  #    default: :float,
  #    allow_nil: false,
  #    one_of: [:float, :fraction]
  #  },
  #  precision: %{
  #    doc: "Only applies when the `probability_type` is `:float`. Probability floats will be rounded to this number of decimal places",
  #    default: 3,
  #    allow_nil: false,
  #    one_of: :integer
  #  },
  #  take: %{
  #    doc: "If used, then instead of returning one random value, will return a list (size == :take) of random values",
  #    default: nil,
  #    allow_nil: true,
  #    one_of: :integer
  #  },
  #]

  #_todo = ~s"""
  #@TODO auto generate docs for all the config options
  #"""

  #def merge_opts(user_opts, default_opts \\ []) when is_list(user_opts) and is_list(default_opts) do
  #  opts =
  #    default_opts
  #    |> Keyword.merge(config_opts())
  #    |> Keyword.merge(user_opts)

  #  Keyword.put_new(opts, :backend, get_backend())
  #end

  #defp config_opts() do
  #  Enum.map(@config_opts, fn {k, %{default: d}} ->
  #    o =
  #      case Application.fetch_env(:weighted_random, k) do
  #        {:ok, c} -> c
  #        :error -> d
  #      end

  #    {k, o}
  #  end)
  #end



  # Given a kwli of opts, and a schema, remove all keys from opts that are NOT in the schema.
  def sanitize(opts, %NimbleOptions{schema: schema}) do
    keys = Keyword.keys(schema)
    Keyword.take(opts, keys)
  end


end
