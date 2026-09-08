defmodule WeightedRandom.Exceptions.EmptyOutcomes do
  defexception []

  @impl true
  def message(_t) do
    "Outcomes must not be empty"
  end

  @impl true
  def exception(_value) do
    struct(__MODULE__, %{})
  end
end
