defmodule WeightedRandom.Backend.RuntimeList do
  use WeightedRandom.Backend

  defstruct [
    li: [],
    # int_map: [],
    # weights: [],
    # opts: [],
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


  #defp rand_ints(li, weights, opts) do
  #  custom_weights = Enum.map(weights, &Weight.new(&1, opts))
  #  side_effects = Enum.map(custom_weights, &Weight.create_side_effect_weights/1)

  #  li =
  #    (Weight.convert_to_values(custom_weights) ++
  #       Weight.convert_to_values(side_effects) ++
  #       Enum.map(li, & &1))
  #    |> Enum.filter(&(&1 in li))

  #  Enum.random(li)
  #end


end
