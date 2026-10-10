defmodule WeightedRandom.Backend.WalkerAlias do
  @moduledoc ~s"""
  A more 'idiomatically elixir' implementation of The Walker Alias Method. Uses the `WeightedRandom.Backend` behaviour

  The original algorithm is described in detail [on wikipedia](https://en.wikipedia.org/wiki/Alias_method).
  """
  alias __MODULE__.{Preprocess, Buckets, Table}
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
  # The usual 'Happy Path'
  def take(%Table{bucket_tuple: buckets, size: size}, count) when is_tuple(buckets) do
    for _ <- 1..count//1 do
      buckets |> elem(:rand.uniform(size) - 1) |> flip_coin()
    end
  end

  # When the list of possible outcomes is bigger than erlangs tuple size limit
  def take(%Table{bucket_tuple: nil, buckets: buckets, size: size}, count) when is_integer(size) and size > @max_tuple_size do
    for _ <- 1..count//1 do
      buckets |> Enum.at(:rand.uniform(size) - 1) |> flip_coin()
    end
  end

  # This clause only exists in case someone deserialized the struct into a plain map
  # that has `:buckets` but no usable `:bucket_tuple`.
  def take(%{buckets: buckets}, count) do
    take(Table.from_buckets(buckets), count)
  end


  defp flip_coin({split_point, lower, higher}) do
    if :rand.uniform() <= split_point, do: lower, else: higher
  end


end
