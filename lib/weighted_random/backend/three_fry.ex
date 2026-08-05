defmodule WeightedRandom.Backend.ThreeFry do
  @moduledoc ~s"""
  This backend is a simple wrapper around the Nx.Random module which uses the ThreeFry algorithm.

  This one is a bit unusual in the sense that you can pass in an (integer) key in the `opts` to ensure reproducible results.
  It also returns a tuple of `{key, results}` instead of the usual `results`.

  ## Examples
      iex> table = WeightedRandom.preprocess(outcomes, probabilities, backend: WeightedRandom.Backend.ThreeFry)
      iex> {_new_key, [1, 7]} = WeightedRandom.take(table, 2 key: 42, backend: WeightedRandom.Backend.ThreeFry)
      iex> {new_key, [1, 7]} = WeightedRandom.take(table, 2 key: 42, backend: WeightedRandom.Backend.ThreeFry)
      iex> {_new_key, [5, 4]} = WeightedRandom.take(table, 2 key: new_key, backend: WeightedRandom.Backend.ThreeFry)

  """
  use WeightedRandom.Backend

  defstruct [
    :probabilities,
    :tensor 
  ]

  @impl true
  def options() do
    [probability_type: :float, with_index: false]
  end

  @impl true
  def preprocess(probabilities, _opts \\ []) do
    struct(__MODULE__, %{
      probabilities: Nx.tensor(probabilities),
      tensor: Nx.iota({1, Enum.count(probabilities)})
    })
  end

  @impl true
  def take(%__MODULE__{probabilities: probabilities, tensor: tensor}, count, opts) do
    key = case Keyword.get(opts, :key, System.os_time()) do
      t when is_struct(t, Nx.Tensor) -> t
      i -> Nx.Random.key(i)
  end
    {result, key2} = Nx.Random.choice(key, tensor, probabilities, samples: count)
    li = Nx.to_list(result)
    {key2, li}
  end

end

