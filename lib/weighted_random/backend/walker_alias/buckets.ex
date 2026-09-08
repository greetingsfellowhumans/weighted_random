defmodule WeightedRandom.Backend.WalkerAlias.Buckets.Sorter do
  @moduledoc false
  import Equalish

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

  def add_singlet(sorter, {_, i}), do: add_bucket(sorter, {0.0, i, i})

  def rm_higher(%{highers: [_hd | highers]} = sorter), do: %{sorter | highers: highers}
  def rm_lower(%{lowers: [_hd | lowers]} = sorter), do: %{sorter | lowers: lowers}

  def is_full?(%{lowers: [], highers: []}), do: true
  def is_full?(_sorter), do: false

  def drain_higher(%{highers: [{hp, hi} | _buckets]} = sorter, amount) do
    sorter
      |> rm_higher()
      |> add_higher({hp - amount, hi})
  end


  def is_high_singlet?(sorter, tolerance) do
    case sorter do
      %{bucket_size: bucket_size, highers: [{p, _} | _]} ->
        is_eq_ish(bucket_size, p, tolerance)
      _ -> false
    end
  end
  def is_low_singlet?(sorter, tolerance) do
    case sorter do
      %{bucket_size: bucket_size, lowers: [{p, _} | _]} ->
        is_eq_ish(bucket_size, p, tolerance)
      _ -> false
    end
  end

  def is_final_high?(%{lowers: [], highers: [_last]}), do: true
  def is_final_high?(_), do: false

  def is_final_low?(%{lowers: [_last], highers: []}), do: true
  def is_final_low?(_), do: false

  def can_donate?(%{bucket_size: size, lowers: [{lp, _} | _], highers: [{hp, _} | _]}, tolerance) do
    missing = size - lp
    remainder = hp - missing
    is_gte_ish(remainder, 0.0, tolerance)
  end
  def can_donate?(_), do: false
end

defmodule WeightedRandom.Backend.WalkerAlias.Buckets do
  @moduledoc false
  #alias WeightedRandom.Backend.WalkerAlias.Types, as: BackendT
  #alias WeightedRandom.Utils.Types, as: T
  alias __MODULE__.Sorter
  import Sorter
  import Equalish

  @default_tolerance 1.0e-10

  def fill_all(sorter, tolerance \\ @default_tolerance) do
    if Sorter.is_full?(sorter) do
      sorter
    else
      fill_next(sorter, tolerance)
        |> fill_all()
    end
  end

  def fill_next(sorter, tolerance \\ @default_tolerance) do
    with {:full, false} <- {:full, Sorter.is_full?(sorter)},
         {:high_singlet, false} <- {:high_singlet, Sorter.is_high_singlet?(sorter, tolerance)},
         {:low_singlet, false} <- {:low_singlet, Sorter.is_low_singlet?(sorter, tolerance)},
         {:final_high, false} <- {:final_high, Sorter.is_final_high?(sorter)},
         {:final_low, false} <- {:final_low, Sorter.is_final_low?(sorter)},
         {:can_donate, false} <- {:can_donate, Sorter.can_donate?(sorter, tolerance)}
    do
      dbg sorter
      raise "Unknown state filling next bucket"
    else
      {:full, true} -> sorter
      {:high_singlet, true} -> add_higher_singlet(sorter)
      {:low_singlet, true} -> add_lower_singlet(sorter)
      {:final_high, true} -> add_higher_singlet(sorter)
      {:final_low, true} -> add_lower_singlet(sorter)
      {:can_donate, true} -> donate(sorter, tolerance)
    end
  end

  def donate(%{bucket_size: bucket_size, lowers: [{lp, li} | _], highers: [{hp, hi} | _]} = sorter, tolerance) do
    new_bucket = {lp / bucket_size, li, hi}

    remainder = bucket_size - lp
    new_higher = {hp - remainder, hi}

    sorter
      |> add_bucket(new_bucket)
      |> rm_lower()
      |> rm_higher()
      |> add_depleted_higher(new_higher, tolerance)
  end

  defp add_higher_singlet(%Sorter{highers: [singlet | _]} = sorter) do
    add_singlet(sorter, singlet)
      |> rm_higher()
  end
  defp add_lower_singlet(%Sorter{lowers: [singlet | _]} = sorter) do
    add_singlet(sorter, singlet)
      |> rm_lower()
  end


#@doc ~s"""
#Create buckets in a list.
#Every 'bucket' is a tuple of `{split_point, lower_index, higher_index}`
  #"""
  #@spec fill_buckets(lower :: T.indexed_probabilities(), upper :: T.indexed_probabilities(), bucket_size :: float()) :: list(BackendT.bucket())
  #def fill_buckets(lower, higher, bucket_size, opts \\ []) do
  #  Sorter.new(lower, higher, bucket_size)
  #    |> fill_while(opts)
  #end

  # This acts like a while loop, breaking up the recursion slightly for easier debugging of one step at a time.
  #def fill_while(sorter), do: fill_while(sorter, [])
  #def fill_while(%{lowers: [], highers: []} = sorter, _opts), do: sorter
  #def fill_while(sorter, opts) do
  #  sorter
  #    |> handle_singlets(opts)
  #    |> fill()
  #    |> fill_while(opts)
  #end



  #def fill(%{lowers: [], highers: []} = sorter), do: sorter

  #def fill(%{lowers: [{lp, li} | _], highers: [{hp, hi} | _], bucket_size: bucket_size} = sorter) when lp + hp >= bucket_size do
  #  new_bucket = {lp / bucket_size, li, hi}

  #  remainder = bucket_size - lp
  #  new_higher = {hp - remainder, hi}

  #  sorter
  #    |> add_bucket(new_bucket)
  #    |> rm_lower()
  #    |> rm_higher()
  #    |> sort_depleted_higher(new_higher)
  #end

  ## End of the line, only one remaining. It must be a singlet, but it might have been missed due to floating point errors
  #def fill(%{lowers: [{_p, i}], highers: []} = sorter) do
  #  add_singlet(sorter, i)
  #end
  #def fill(%{lowers: [], highers: [{_p, i}]} = sorter) do
  #  add_singlet(sorter, i)
  #end
  #def fill(%{bucket_size: bucket_size, lowers: [], highers: [{p, i} | _highers]} = sorter) when p > bucket_size do
  #  sorter
  #    |> add_singlet(i)
  #    |> rm_higher()
  #    |> add_higher({p - bucket_size, i})
  #end
  #def fill(%{bucket_size: bucket_size, lowers: [], highers: [{p, i} | _highers]} = sorter) when p < bucket_size do
  #  sorter
  #    |> add_lower({p, i})
  #    |> rm_higher()
  #end


  #defp sort_depleted_higher(%{bucket_size: bucket_size} = sorter, {hp, hi}, tolerance) when is_gte_ish(hp, bucket_size, tolerance), do: add_higher(sorter, {hp, hi})
  #defp sort_depleted_higher(%{bucket_size: bucket_size, lowers: [{lp, _li} | _]} = sorter, {hp, hi}, tolerance) when is_gte_ish(hp + lp, bucket_size, tolerance), do: add_higher(sorter, {hp, hi})
  #defp sort_depleted_higher(sorter, {hp, hi}, _tolerance), do: add_lower(sorter, {hp, hi})


  defp add_depleted_higher(%{bucket_size: size} = sorter, {hp, _hi} = bucket, tolerance) do
    case sorter do
      %{lowers: [{lp, _} | _]} when is_gte_ish(lp + hp, size, tolerance) ->
        add_higher(sorter, bucket)
      _ when is_gte_ish(hp, size, tolerance) ->
        add_higher(sorter, bucket)
      _ ->
        add_lower(sorter, bucket)
    end
  end


end
