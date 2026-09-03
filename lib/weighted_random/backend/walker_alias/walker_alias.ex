defmodule WeightedRandom.Backend.WalkerAlias2 do
  @moduledoc ~s"""
  This is my implementation of the Walker Alias Method.

  I have changed several aspects of the original algorithm in order to make it more idiomatically elixir, and more readable for programmers.

  I suspect it also has performance improvements over similar elixir libraries because of those choices, although I have not yet benchmarked to test it.
  """
  alias __MODULE__.{Preprocess, Buckets, Table}
  use WeightedRandom.Backend

  @impl true
  def options() do
    [probability_type: :probabilities]
  end

  @impl true
  def preprocess(probabilities, _opts) do
    {lows, highs, mean} = Preprocess.prep_numbers(probabilities)
    Buckets.fill_buckets(lows, highs, mean)
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
