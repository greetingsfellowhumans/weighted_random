#defmodule WeightedRandom.Backend.DataframeWalker do
#  @moduledoc ~s"""
#  Based on the [Alias Method](https://en.wikipedia.org/wiki/Alias_method).
#
#  where U_i, or the probability table, is represented as the `:probabilities` series in a DataFrame.
#  and K_i, or the alias table, is represented as the `:aliases` series in a DataFrame.
#  """
#  use WeightedRandom.Backend
#  @type index() :: non_neg_integer()
#  @type probability() :: float()
#  @type probabilities() :: list(float())
#  @type p_table() :: list({probability(), index()})
#  @type mean() :: float()
#
#  @enforce_keys [:probabilities, :aliases, :metadata]
#  defstruct [:probabilities, :aliases, :metadata]
#
#  @type t :: %__MODULE__{
#    probabilities: list(float()),
#    aliases: {list(), list()},
#    metadata: map()
#  }
#
#  @impl true
#  def options() do
#    [probability_type: :float, with_index: false]
#  end
#
#  @impl true
#  def preprocess(probabilities, _opts) do
#    mean = get_mean_probability(probabilities)
#    tables = split_tables(probabilities, mean)
#    tables = fill_tables(tables, mean)
#    dbg tables
#    struct(__MODULE__, %{})
#  end
#
#  @impl true
#  def take(table, _count) do
#    []
#  end
#
#  ## Private
#  defp get_mean_probability(probabilities) do
#    p_sum = 1.0 # No need to calculate, trust the promise of the WeightedRandom contract.
#    p_count = Enum.count(probabilities)
#    (p_sum / p_count)
#  end
#  @spec split_tables(probabilities(), mean()) :: {under_full :: p_table(), full :: p_table(), over_full :: p_table()}
#  defp split_tables(probabilities, mean) do
#      probabilities
#      |> Enum.with_index()
#      |> Enum.reverse()
#      |> Enum.reduce({[], [], []}, fn 
#        {probability, _idx} = p, {under, full, over} when probability < mean -> {[p | under], full, over}
#        {probability, idx} = p, {under, full, over} when probability == mean -> {under, [p | full], over}
#        {probability, _idx} = p, {under, full, over} when probability > mean -> {under, full, [p | over]}
#    end)
#      |> sort_tables()
#  end
#
#  # For unders, we want smallest first.
#  # For overs, we want largest first.
#  defp sort_tables({under, full, over}) do
#    {
#      Enum.sort_by(under, fn {prob, _idx} -> prob end, :asc),
#      full,
#      Enum.sort_by(over, fn {prob, _idx} -> prob end, :desc),
#    }
#  end
#
#  defp fill_tables(tables, mean) do
#    case tables do
#      {[under_hd | under_tl], full, [over_hd | over_tl]} ->
#        {up, ui} = under_hd
#        {op, oi} = over_hd
#        under_by = mean - up
#        new_op = op - under_by
#        new_table = {under_tl, [{}]}
#
#
#    end
#  end
#end
