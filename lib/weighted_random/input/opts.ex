defmodule WeightedRandom.Input.Opts do
  @moduledoc false
  alias WeightedRandom.Backend.Opts, as: BackendOpts
  alias WeightedRandom.Utils.Opts, as: Utils

  @weight_spec [
    target: [
      doc: ~s"""
      If `outcome_type: :index`, then `:target` must be an integer.

      If `outcome_type: :value`, then `:target` must be one of the items in the list of `outcomes`.
      """,
      type: :any,
      required: true
    ],
    amount: [
      doc: ~s"""
      The amount of weight to add to the target outcome.

      Before any weights have been added, every outcome already has a weight of 1.0. Therefore adding a new `:amount` of 1, will set it to 2.0 in total.
      """,
      type: {:or, [:integer, :float]},
      required: true
    ],
    left_dist: [
      doc: ~s"""
      The number of outcomes *before* `:target` to receive weight when a `:curve` is used.
      """,
      type: :integer,
      default: 0
    ],
    right_dist: [
      doc: ~s"""
      The number of outcomes *after* `:target` to receive weight when a `:curve` is used.
      """,
      type: :integer,
      default: 0
    ],
    radius: [
      doc: ~s"""
      The number of outcomes on either side of `:target` to receive weight when a `:curve` is used. Overridden by `:left_dist` and `:right_dist`.
      """,
      type: :integer,
      default: 0
    ],
    curve: [
      doc: ~s"""
      The value passed into `Curves.define_bezier/2` to generate a bezier curve.
      """,
      type: {:or, [:atom, {:list, {:tuple, [{:or, [:integer, :float]}, {:or, [:integer, :float]}]}}]},
      required: false
    ]
  ] 
  @weight_spec_schema @weight_spec |> NimbleOptions.new!()
  def weight_spec(), do: @weight_spec
  def weight_spec_schema(), do: @weight_spec_schema

  @weights [
    weights: [
      doc: "A list of weight specs",
      type: {:list, @weight_spec},
      default: []
    ]
  ]
  def weights(), do: @weights |> NimbleOptions.new!()


  @outcome_type [
    doc: ~s"""
    When you take a random sample, will it return the index of an outcome, or the value?

    - `index:` pick random indices from the list of outcomes. For example if your outcomes are `125..130` then the results will be between `0` and `5`.
    - `value:` pick random values from the list of outcomes. For example if your outcomes are `125..130` then the results will be between `125` and `130`.
    """,
    default: :index,
    type: {:in, [:index, :value]},
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

  @rand_p_docs NimbleOptions.new!([
    backend: BackendOpts.backend(false),
    precision: @precision,
    take: @take,
  ])
  def rand_p_docs(), do: @rand_p_docs


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

  # Because we do a little extra work involing config files to get the :backend, it is not required at the beginning of the function.
  # In the docs, it defaults to WalkerAlias, but in the Nimble validation it is set to required.
  @rand_schema NimbleOptions.new!([
    take: @take,
    backend: BackendOpts.backend(),
  ])
  @rand_docs NimbleOptions.new!([
    take: @take,
    backend: BackendOpts.backend(false),
  ])
  def rand_schema(), do: Utils.merge([from_weights_schema(), @rand_schema])
  def rand_docs(), do: Utils.merge([from_weights_schema(), @rand_docs])
  def rand_merge_opts(opts) do
    opts
    |> index_adapter()
    |> WeightedRandom.Utils.Opts.sanitize(@rand_schema)
    |> WeightedRandom.Backend.Opts.add_backend()
    |> NimbleOptions.validate!(@rand_schema)
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
