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
  def take(table, count) do
    for _ <- 1..count do
      coin_flip = :rand.uniform()

      case Enum.random(table.buckets) do
        {split_point, _lower, higher} when split_point < coin_flip -> higher
        {split_point, lower, _higher} when split_point >= coin_flip -> lower
      end

    end
  end


end
