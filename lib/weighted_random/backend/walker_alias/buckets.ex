defmodule WeightedRandom.Backend.WalkerAlias2.Buckets.Sorter do
  @moduledoc false
  defstruct [
    :bucket_size,
    lowers: [],
    highers: [],
    buckets: []
  ]
  def new(lowers, highers, bucket_size) do
    struct(__MODULE__, %{
      lowers: lowers, highers: highers, bucket_size: bucket_size
    })
  end

  def add_bucket(sorter, {_split_point, _idx1, _idx2} = bucket) do
    Map.put(sorter, :buckets, [bucket | sorter.buckets])
  end
  def add_lower(%{lowers: lowers} = sorter, l), do: Map.put(sorter, :lowers, [l | lowers])
  def add_higher(%{highers: highers} = sorter, h), do: Map.put(sorter, :highers, [h | highers])

  def add_singlet(sorter, i), do: add_bucket(sorter, {0.0, i, i})

  def rm_higher(%{highers: [_hd | highers]} = sorter), do: %{sorter | highers: highers}
  def rm_lower(%{lowers: [_hd | lowers]} = sorter), do: %{sorter | lowers: lowers}
end

defmodule WeightedRandom.Backend.WalkerAlias2.Buckets do
  @moduledoc false
  #alias WeightedRandom.Backend.WalkerAlias2.Types, as: BackendT
  #alias WeightedRandom.Utils.Types, as: T
  alias WeightedRandom.Utils.Analysis
  alias WeightedRandom.Backend.WalkerAlias2.Buckets.Sorter
  import Sorter

  @default_tolerance 0.00001

  @doc ~s"""
  Create buckets in a list.
  Every 'bucket' is a tuple of `{split_point, lower_index, higher_index}`
  """
  #@spec fill_buckets(lower :: T.indexed_probabilities(), upper :: T.indexed_probabilities(), bucket_size :: float()) :: list(BackendT.bucket())
  def fill_buckets(lower, higher, bucket_size, opts \\ []) do
    Sorter.new(lower, higher, bucket_size)
      |> fill_while(opts)
  end

  # This acts like a while loop, breaking up the recursion slightly for easier debugging of one step at a time.
  def fill_while(sorter), do: fill_while(sorter, [])
  def fill_while(%{lowers: [], highers: []} = sorter, _opts), do: sorter
  def fill_while(sorter, opts) do
    sorter
      |> handle_singlets(opts)
      |> fill()
      |> fill_while(opts)
  end


  def high_singlet?(sorter, tolerance) do
    case sorter do
      %{bucket_size: bucket_size, highers: [{p, _} | _]} ->
        Analysis.equalish?(bucket_size, p, tolerance)
      _ -> false
    end
  end
  def low_singlet?(sorter, tolerance) do
    case sorter do
      %{bucket_size: bucket_size, lowers: [{p, _} | _]} ->
        Analysis.equalish?(bucket_size, p, tolerance)
      _ -> false
    end
  end


  # TODO refactor. This is unreadable
  def handle_singlets(sorter, opts) do
    tolerance = Keyword.get(opts, :tolerance, @default_tolerance)
    cond do
      high_singlet?(sorter, tolerance) ->
        %{highers: [{_, i} | _]} = sorter
        add_singlet(sorter, i)
          |> rm_higher()
          |> handle_singlets(opts)
      low_singlet?(sorter, tolerance) ->
        %{lowers: [{_, i} | _]} = sorter
        add_singlet(sorter, i)
          |> rm_lower()
          |> handle_singlets(opts)
      true -> sorter
    end
  end

  def fill(%{lowers: [], highers: []} = sorter), do: sorter

  def fill(%{lowers: [{lp, li} | _], highers: [{hp, hi} | _], bucket_size: bucket_size} = sorter) when lp + hp >= bucket_size do
    new_bucket = {lp / bucket_size, li, hi}

    remainder = bucket_size - lp
    new_higher = {hp - remainder, hi}

    sorter
      |> add_bucket(new_bucket)
      |> rm_lower()
      |> rm_higher()
      |> sort_depleted_higher(new_higher)
  end

  # End of the line, only one remaining. It must be a singlet, but it might have been missed due to floating point errors
  def fill(%{lowers: [{_p, i}], highers: []} = sorter) do
    add_singlet(sorter, i)
  end
  def fill(%{lowers: [], highers: [{_p, i}]} = sorter) do
    add_singlet(sorter, i)
  end
  def fill(%{bucket_size: bucket_size, lowers: [], highers: [{p, i} | _highers]} = sorter) when p > bucket_size do
    sorter
      |> add_singlet(i)
      |> rm_higher()
      |> add_higher({p - bucket_size, i})
  end
  def fill(%{bucket_size: bucket_size, lowers: [], highers: [{p, i} | _highers]} = sorter) when p < bucket_size do
    sorter
      |> add_lower({p, i})
      |> rm_higher()
  end


  defp sort_depleted_higher(%{bucket_size: bucket_size} = sorter, {hp, hi}) when hp >= bucket_size, do: add_higher(sorter, {hp, hi})
  defp sort_depleted_higher(%{bucket_size: bucket_size, lowers: [{lp, _li} | _]} = sorter, {hp, hi}) when hp + lp >= bucket_size, do: add_higher(sorter, {hp, hi})
  defp sort_depleted_higher(%{} = sorter, {hp, hi}), do: add_lower(sorter, {hp, hi})

end
