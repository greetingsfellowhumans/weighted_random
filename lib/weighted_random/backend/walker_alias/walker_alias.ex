defmodule WeightedRandom.Backend.WalkerAlias do
  @moduledoc ~s"""
  A more 'idiomatically elixir' implementation of The Walker Alias Method. Uses the `WeightedRandom.Backend` behaviour

  The original algorithm is described in detail [on wikipedia](https://en.wikipedia.org/wiki/Alias_method).
  """
  alias __MODULE__.{Preprocess, Buckets, Table}
  alias WeightedRandom.Backend.Mwc59
  use WeightedRandom.Backend

  @impl true
  def options() do
    [probability_type: :probabilities]
  end

  @impl true
  def preprocess(probabilities, opts) do
    {lows, highs, mean} = Preprocess.prep_numbers(probabilities)
    sorter = Buckets.Sorter.new(lows, highs, mean)
    Buckets.fill_all(sorter, opts[:tolerance])
      |> Table.new()
  end

  @max_tuple_size WeightedRandom.Backend.max_tuple_size()

  @impl true
  # A single sample. Seeding `:rand.mwc59/1` costs more than it saves here, so use `:rand` directly.
  # The coin is flipped before the bucket is picked, the same order as 1.0.x, so seeded single values are unchanged.
  def take(%Table{bucket_tuple: buckets, size: size}, 1) when is_tuple(buckets) do
    coin = :rand.uniform()
    [buckets |> elem(:rand.uniform(size) - 1) |> flip_coin(coin)]
  end

  # The usual 'Happy Path'
  def take(%Table{bucket_tuple: buckets, size: size}, count) when is_tuple(buckets) do
    take_tuple(buckets, size, count, Mwc59.seed(), [])
  end

  # When the list of possible outcomes is bigger than erlangs tuple size limit
  def take(%Table{bucket_tuple: nil, buckets: buckets, size: size}, count) when is_integer(size) and size > @max_tuple_size do
    take_list(buckets, size, count, Mwc59.seed(), [])
  end

  # This clause only exists in case someone deserialized the struct into a plain map
  # that has `:buckets` but no usable `:bucket_tuple`.
  def take(%{buckets: buckets}, count) do
    take(Table.from_buckets(buckets), count)
  end


  defp take_tuple(_buckets, _size, count, _cx, acc) when count <= 0, do: Enum.reverse(acc)
  defp take_tuple(buckets, size, count, cx0, acc) do
    cx1 = :rand.mwc59(cx0)
    cx2 = :rand.mwc59(cx1)
    sample = buckets |> elem(Mwc59.index(cx1, size)) |> flip_coin(:rand.mwc59_float(cx2))
    take_tuple(buckets, size, count - 1, cx2, [sample | acc])
  end

  defp take_list(_buckets, _size, count, _cx, acc) when count <= 0, do: Enum.reverse(acc)
  defp take_list(buckets, size, count, cx0, acc) do
    cx1 = :rand.mwc59(cx0)
    cx2 = :rand.mwc59(cx1)
    sample = buckets |> Enum.at(Mwc59.large_index(cx1, size)) |> flip_coin(:rand.mwc59_float(cx2))
    take_list(buckets, size, count - 1, cx2, [sample | acc])
  end

  defp flip_coin({split_point, lower, higher}, coin) do
    if coin <= split_point, do: lower, else: higher
  end
end
