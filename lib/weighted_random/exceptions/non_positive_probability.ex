defmodule WeightedRandom.Exceptions.NonPositiveProbability do
  defexception [:value]

  @impl true
  def message(t) do
    "Expected probability to be a float greater than 0.0. Instead, got: #{t.value}"
  end

  @impl true
  def exception(value) do
    value = case value do
      li when is_list(li) -> 
        strings = Enum.map(li, &("#{&1}"))
                  |> Enum.join(", ")
        "[#{strings}]"
      s when is_binary(s) -> s
    end
    struct(__MODULE__, %{value: value})
  end
end
