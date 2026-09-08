defmodule WeightedRandom.Exceptions.NonFloatProbabilities do
  defexception [:values]

  @impl true
  def message(t) do
    "Probabilities must not be floats. Got #{inspect t.values}"
  end

  @impl true
  def exception(values) do
    struct(__MODULE__, %{values: values})
  end
end
