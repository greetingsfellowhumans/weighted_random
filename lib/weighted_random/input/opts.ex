defmodule WeightedRandom.Input.Opts do
  @moduledoc false
  alias WeightedRandom.Backend.Opts, as: BackendOpts


  @outcome_type [
    doc: ~s"""
    When you take a random sample, will it return the index of an outcome, or the value?

    - `index:` pick random indices from the list of outcomes. For example if your outcomes are `125..130` then the results will be between `0` and `5`.
    - `value:` pick random values from the list of outcomes. For example if your outcomes are `125..130` then the results will be between `125` and `130`.
    """,
    default: :index,
    type: {:in, [:index, :value]},
  ]

  @probability_type [
    doc: ~s"""
    How will the algorithm determine bias?

    `probability:` Expects a list of floats between `0.0` and `1.0`. They should add up to `1.0`. but if not, they'll be automatically normalized until they do.
    `weight:` Every outcome has a default weight of `1.0`. The list of weights can alter this in an additive way.
    """,
    required: true,
    type: {:in, [:probability, :weight]},
  ]

  @precision [
    doc: ~s"""
    The number of decimal places to use when rounding. Leave nil for no rounding.
    """,
    required: false,
    type: :pos_integer
  ]

  @take [
    doc: "If used, then instead of returning one random value, will return a list (size == :take) of random values",
    required: false,
    type: :pos_integer
  ]

  #def outcome_type(), do: @outcome_type
  #def probability_type(), do: @probability_type

  @from_probabilities_schema NimbleOptions.new!([
    backend: BackendOpts.backend(),
    precision: @precision,
  ])
  def from_probabilities_schema(), do: @from_probabilities_schema

  def from_probabilities_merge_opts(opts) do
    opts
    |> WeightedRandom.Utils.Opts.sanitize(@from_probabilities_schema)
    |> WeightedRandom.Backend.Opts.add_backend()
    |> NimbleOptions.validate!(@from_probabilities_schema)
    |> Keyword.put(:probability_type, :probability)
    |> Keyword.put(:outcome_type, :index)
  end


  @rand_p_schema NimbleOptions.new!([
    backend: BackendOpts.backend(),
    precision: @precision,
    take: @take,
  ])
  def rand_p_schema(), do: @rand_p_schema


  @from_weights_schema NimbleOptions.new!([
    backend: BackendOpts.backend(),
    precision: @precision,
    outcome_type: @outcome_type,
  ])
  def from_weights_schema(), do: @from_weights_schema
  def from_weights_merge_opts(opts) do
    opts
    |> index_adapter()
    |> WeightedRandom.Utils.Opts.sanitize(@from_weights_schema)
    |> WeightedRandom.Backend.Opts.add_backend()
    |> NimbleOptions.validate!(@from_weights_schema)
    |> Keyword.put(:probability_type, :weight)
  end

  # the key `:outcome_type` replaces the old deprecated key `:index`.
  # This function makes it backwards compatible
  def index_adapter(opts) do
    case opts[:index] do
      true -> Keyword.put(opts, :outcome_type, :index)
      false -> Keyword.put(opts, :outcome_type, :value)
      _ -> opts
    end
  end
end
