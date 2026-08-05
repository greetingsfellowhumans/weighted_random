defmodule WeightedRandom.Backend do
  @moduledoc ~s"""
  WeightedRandom.Backend offers a contract to all who implement it:
  1. The main WeightedRandom package presents a novel interface for generating a list of probabilities (floats that can be summed to equal exactly 1.0).
  2. The custom Backend module decides what to do with those probabilities once they are generated.

  """

  @enforce_keys [:outcomes, :backend, :table]
  defstruct [:outcomes, :backend, :table]

  @type t :: %__MODULE__{
    outcomes: list(),
    backend: atom(),
    table: struct()
  }

  @type fraction() :: {numerator :: integer(), denominator :: integer()}
  @type fractions() :: list(fraction())
  @type percentage() :: float()
  @type index() :: integer()
  @type indices() :: list(index())
  @type probability() :: fraction() | percentage()
  @type opts() :: keyword()
  @type table() :: struct()
  @type random_key :: integer() | Nx.Tensor.t()


  @doc ~s"""
  `weights` is a list of floats which, if summed, would equal exactly 1.0. Each float represents the probability of being selected in the random sample.

  So if given `[0.25, 0.25, 0.5]`, then index 2 is twice as likely to be sampled as index 1.

  This function must return some kind of struct that will later be passed into `take/2`.
  """
  @callback preprocess(probabilities :: list({probability(), index()}), opts()) :: table()

  @doc ~s"""
  Given the struct returned by `preprocess/2`, return a list of random indices equal to `count`.
  """
  @callback take(table :: struct(), count :: integer(), opts :: list()) :: indices() | {random_key(), indices()}

  @doc ~s"""
  Optionally provide the opts kwli 
  """
  @callback options() :: keyword()
  @optional_callbacks options: 0


  def preprocess(backend, outcomes, probabilities, opts) do
    table = backend.preprocess(probabilities, opts)
    struct!(__MODULE__, %{
      table: table,
      backend: backend,
      outcomes: outcomes,
    })
  end
  def take(%{backend: backend, table: table}, count, opts \\ []) do
    backend.take(table, count, opts)
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour WeightedRandom.Backend

      def options(), do: []
      defoverridable options: 0

    end
  end
end
