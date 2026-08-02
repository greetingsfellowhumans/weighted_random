defmodule WeightedRandom.Backend.WalkerAlias do

  defstruct [:values, :probs, :aliases, :size]

  @type t :: %__MODULE__{
    values: tuple(),
    probs: tuple(),
    aliases: tuple(),
    size: non_neg_integer()
  }

  @spec new(list()) :: t()
  def new(data) when is_list(data) do
    {values, weights} = data |> Enum.reverse() |> Enum.reduce({[], []}, fn {v, w}, {vs, ws} -> {[v|vs], [w|ws]} end)
    new(values, weights)
  end

  @spec new(map()) :: t()
  def new(data) when is_map(data) do
    new(Map.keys(data), Map.values(data))
  end

  @spec new(list(), list()) :: t()
  def new(values, weights) when is_list(values) and is_list(weights) and length(values) == length(weights) do
    values = List.to_tuple(values)
    size = tuple_size(values)
    {aliases, probs} = generate(weights, size)

    %__MODULE__{values: values, probs: probs, aliases: aliases, size: size}
  end

  @spec fetch(t(), non_neg_integer(), float()) :: {:ok, term()} | {:error, :invalid_index}
  def fetch(%__MODULE__{values: values} = wam, index, rng) do
    with {:ok, rindex} <- index(wam, index, rng) do
      {:ok, elem(values, rindex)}
    end
  end

  @spec get(t(), non_neg_integer(), float(), term()) :: term()
  def get(%__MODULE__{} = wam, index, rng, default \\ nil) do
    case fetch(wam, index, rng) do
      {:ok, value} ->
        value

      _error ->
        default
    end
  end

  @spec index(t(), non_neg_integer(), float()) :: {:ok, non_neg_integer()} | {:error, :invalid_index}
  def index(%__MODULE__{probs: probs, aliases: aliases, size: size}, index, rng) when index < size do
    prob = elem(probs, index)
    rindex = if(rng < prob, do: elem(aliases, index), else: index)
    {:ok, rindex}
  end

  def index(%__MODULE__{}, _index, _rng) do
    {:error, :invalid_index}
  end

  defp generate(weights, size) do
    generate_tables(weights, Enum.sum(weights), size)
  end

  defp generate_tables(_weights, 0, size) do
    {Tuple.duplicate(0, size), Tuple.duplicate(0.0, size)}
  end

  defp generate_tables(weights, sum, size) do
    mean = sum / size
    {below, above} = separate_weight(weights, mean)

    generate_tables_recursive(
      below,
      above,
      mean,
      Tuple.duplicate(0, size),
      Tuple.duplicate(0.0, size)
    )
  end

  defp generate_tables_recursive([], _above, _mean, aliases, probs) do
    {aliases, probs}
  end

  defp generate_tables_recursive([below_val | below], [], mean, aliases, probs) do
    {idx, weight} = below_val

    aliases = put_elem(aliases, idx, idx)
    probs = put_elem(probs, idx, weight / mean)

    generate_tables_recursive(below, [], mean, aliases, probs)
  end

  defp generate_tables_recursive([below_val | below], [above_val | above], mean, aliases, probs) do
    {bidx, bweight} = below_val
    {aidx, aweight} = above_val

    diff = mean - bweight

    aliases = put_elem(aliases, bidx, aidx)
    probs = put_elem(probs, bidx, diff / mean)

    if aweight - diff <= mean do
      generate_tables_recursive([{aidx, aweight - diff} | below], above, mean, aliases, probs)
    else
      generate_tables_recursive(below, [{aidx, aweight - diff} | above], mean, aliases, probs)
    end
  end

  defp separate_weight(weights, mean) do
    weights
    |> Enum.with_index()
    |> Enum.reduce({[], []}, fn {w, i}, {b, a} ->
      if(w <= mean, do: {[{i, w} | b], a}, else: {b, [{i, w} | a]})
    end)
  end


end
