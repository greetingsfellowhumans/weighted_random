defmodule WeightedRandom.Exceptions.EmptyProbabilities do
  defexception []

  @impl true
  def message(t) do
    "Probabilities must not be empty"
  end

  @impl true
  def exception(value) do
    struct(__MODULE__, %{})
  end
end
