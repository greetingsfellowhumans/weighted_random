defmodule WeightedRandom.Backend.RuntimeList do
  use WeightedRandom.Backend

  defstruct [
    li: [],
  ]

  @impl true
  def options() do
    [probability_type: :fraction]
  end

  @impl true
  def preprocess(probabilities, _opts) do
    li = Enum.map(probabilities, fn {{weight, _total}, idx} ->
      List.duplicate(idx, round(weight))
    end)
      |> List.flatten()
    struct(__MODULE__, %{li: li})
  end

  @impl true
  def take(%__MODULE__{li: li}, count) do
    Enum.take_random(li, count)
  end

end
