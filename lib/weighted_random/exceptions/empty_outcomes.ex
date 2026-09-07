defmodule WeightedRandom.Exceptions.EmptyOutcomes do
  defexception []

  @impl true
  def message(t) do
    "Outcomes must not be empty"
  end

  @impl true
  def exception(value) do
    struct(__MODULE__, %{})
  end
end
