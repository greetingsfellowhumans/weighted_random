defmodule WeightedRandom.Backend.WalkerAlias2 do

  use WeightedRandom.Backend

  @impl true
  def options() do
    [probability_type: :probabilities]
  end

  @impl true
  def preprocess(probabilities, opts) do
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
