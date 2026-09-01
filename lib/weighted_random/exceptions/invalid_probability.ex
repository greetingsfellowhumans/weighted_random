defmodule WeightedRandom.Exceptions.NonPositiveProbability do
  defexception [:value]

  @impl true
  def message(t) do
    "Expected probability to be a float greater than 0.0. Instead, got: #{t.value}"
  end

  @impl true
  def exception(value) do
    struct(__MODULE__, %{value: value})
  end
end
