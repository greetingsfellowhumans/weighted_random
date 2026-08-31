defmodule WeightedRandom.Backend do
  alias WeightedRandom.Input
  @moduledoc ~s"""
  WeightedRandom.Backend offers a contract to all who implement it:
  1. The main WeightedRandom package presents a novel interface for generating a list of probabilities (floats that can be summed to equal exactly 1.0).
  2. The custom Backend module decides what to do with those probabilities once they are generated.

  To create your own backend, copy the module `WeightedRandom.Backend.Linear` and make changes to the functions.

  To use a different backend, you can either pass it in as an opt (see function docs), or you can put it in your config file:

  ```elixir
  config :weighted_random,
    backend: Your.Backend.Module
  ```

  """

  @enforce_keys [:outcomes, :backend, :table]
  defstruct [:outcomes, :backend, :table]

  @type t :: %__MODULE__{
    outcomes: list(),
    backend: atom(),
    table: struct()
  }

  @type weight() :: Input.Weight.t()
  @type weights() :: list(weight())
  @type percentage() :: float()
  @type index() :: integer()
  @type indices() :: list(index())
  @type opts() :: keyword()
  @type table() :: struct()
  @type probability_type() :: :weights | :probabilities
  @type backend_opts() :: [
    probability_type: probability_type(),
  ]

  def list_probability_types(), do: [:probabilities, :weights]

  @doc ~s"""
  `weights` is a list of floats which, if summed, would equal exactly 1.0. Each float represents the probability of being selected in the random sample.

  So if given `[0.25, 0.25, 0.5]`, then index 2 is twice as likely to be sampled as index 1.

  This function must return some kind of struct that will later be passed into `take/2`.
  """
  @callback preprocess(input :: Input.t(), opts :: opts()) :: table()

  @doc ~s"""
  Given the struct returned by `preprocess/2`, return a list of random indices equal to `count`.
  """
  @callback take(table :: struct(), count :: integer()) :: indices :: list(index :: integer())

  @doc ~s"""
  Optionally provide the opts kwli 
  """
  @callback options() :: keyword()
  @optional_callbacks options: 0


  def preprocess(backend, input, opts) do
    probabilities = Map.get(input, backend.options()[:probability_type])
    table = backend.preprocess(probabilities, opts)
    struct!(__MODULE__, %{
      table: table,
      backend: backend,
      outcomes: input.outcomes,
    })
  end
  def take(%{backend: backend, table: table}, count) do
    backend.take(table, count)
  end


  defmacro __using__(_opts) do
    quote do
      @behaviour WeightedRandom.Backend

      def options(), do: []
      defoverridable options: 0

    end
  end
end
