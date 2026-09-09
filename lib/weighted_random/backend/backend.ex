defmodule WeightedRandom.Backend do
  alias WeightedRandom.Input
  @moduledoc ~s"""
  WeightedRandom.Backend offers a contract to all who implement it:
  1. The main WeightedRandom package presents a novel interface for generating a list of probabilities or weights
  2. The custom Backend module decides what to do with those probabilities once they are generated.
  
  ## Using Backends

  To use a different backend, you can either pass it in as an opt (see function docs), or you can put it in your config file:

  ```elixir
  config :weighted_random,
    backend: Your.Backend.Module
  ```

  ## Developing a new backend

  To create your own backend, copy and change an existing one (like `WeightedRandom.Backend.WalkerAlias` or `WeightedRandom.Backend.Linear`).

  Your module must implement the callbacks listed below: `preprocess/2`, `take/2`, and optionally `options/0`.

  The simplest backend might look like this.

  ```elixir
  defmodule My.Backend do
    use WeightedRandom.Backend

    defstruct [:list]

    @impl true
    def preprocess(probabilities, _opts) do
      struct(__MODULE__, %{list: probabilities})
    end

    @impl true
    def take(%__MODULE__{list: li}, count) do
      for _ <- 1..count do
        Enum.random(li)
      end
    end 

  end
  ```

  This backend doesn't actually apply probability, it is just a glorified `Enum.rand(list)` for now.
  But you can use it in any of the main functions that take an opt of `backend`

  ```elixir
  WeightedRandom.rand(0..10, weights, [backend: My.Backend])
  => 3
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
  @type probabilities() :: list(percentage())
  @type resolved_weights() :: list(float())
  @type index() :: integer()
  @type indices() :: list(index())
  @type opts() :: keyword()
  @type table() :: struct()
  @type probability_type() :: :weights | :probabilities
  @type backend_opts() :: [
    probability_type: probability_type(),
  ]

  @doc false
  def list_probability_types(), do: [:probabilities, :weights]

  @doc ~s"""
  `input` is a list of floats.

  This function must return some kind of struct that will later be passed into `take/2`.

  For details about `opts`, see `WeightedRandom.preprocess` and `WeightedRandom.preprocess_p`.
  """
  @callback preprocess(input :: probabilities() | resolved_weights(), opts :: opts()) :: table()

  @doc ~s"""
  Given the struct returned by `preprocess/2`, return a list of random indices equal to `count`.
  """
  @callback take(table :: struct(), count :: pos_integer()) :: indices :: indices()

  @doc ~s"""
  A keyword list of options that the backend requires from the WeightedRandom library.

  Currently the only option is `:probability_type`, which influences the input argument of `preprocess/2`.
  When set to `:probabilities` (default), the input will be a list of floats that roughly sum to `1.0`.
  When set to `:weights`, the input will be a list of floats.
  """
  @callback options() :: backend_opts()
  @optional_callbacks options: 0


  @doc false
  def preprocess(backend, input, opts) do
    probabilities = Map.get(input, backend.options()[:probability_type])
    table = backend.preprocess(probabilities, opts)
    struct!(__MODULE__, %{
      table: table,
      backend: backend,
      outcomes: input.outcomes,
    })
  end
  @doc false
  def take(%{backend: backend, table: table}, count) do
    backend.take(table, count)
  end


  defmacro __using__(_opts) do
    quote do
      @behaviour WeightedRandom.Backend

      def options(), do: [probability_type: :probabilities]
      defoverridable options: 0

    end
  end
end
