defmodule WeightedRandom.Weight do
  defstruct [
    :target,
    internal_weight: 1,
    total_weight: 1,
    diameter: 0,
    curve_type: :linear,
    data_type: :integer
  ]

  def new(target, weight, opts) do
    body = %{
      target: target,
      internal_weight: weight,
      total_weight: weight,
    }

    body = Map.merge(body, opts)

    struct!(__MODULE__, body)
  end
  
end
