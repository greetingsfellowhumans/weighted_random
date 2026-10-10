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

  @impl true
  def take(%Table{bucket_tuple: buckets, size: size}, count) when is_tuple(buckets) do
    for _ <- 1..count do
      {split_point, lower, higher} = elem(buckets, :rand.uniform(size) - 1)
      if :rand.uniform() <= split_point, do: lower, else: higher
    end
  end
  def take(%{buckets: buckets}, count) do
    # This clause only exists in case someone deserialized the struct into a plain map
    # that has `:buckets` but no usable `:bucket_tuple`.
    bucket_tuple = List.to_tuple(buckets)
    take(%Table{buckets: buckets, bucket_tuple: bucket_tuple, size: tuple_size(bucket_tuple)}, count)
  end


end
