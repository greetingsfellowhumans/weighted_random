defmodule WeightedRandom.Backend.WalkerAlias2 do
  alias __MODULE__.{Preprocess, Buckets}

  use WeightedRandom.Backend

  @impl true
  def options() do
    [probability_type: :probabilities]
  end

  @impl true
  def preprocess(probabilities, opts) do
    sum = Enum.sum(probabilities)
    length = Enum.count(probabilities)
    mean = sum / length

    {lows, highs} = Enum.with_index(probabilities)
                  |> Preprocess.split_probabilities(mean)

    highs = Enum.reverse(highs)
    Buckets.fill_buckets(lows, highs, mean)

    #probabilities
    #  |> Enum.with_index(fn element, index -> {index, element} end)
    #  |> WAM.new()
  end

  @impl true
  def take(table, count) do
    #for _ <- 1..count do
    #  WAM.get(table, :rand.uniform(table.size) - 1, :rand.uniform())
    #end
  end

end
