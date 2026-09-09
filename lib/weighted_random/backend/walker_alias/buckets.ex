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
    is_gte_ish(lp + hp, size, tolerance)
  end
  def can_donate?(%{bucket_size: size, highers: [{hp, _} | _]}, tolerance) do
    is_gte_ish(hp, size, tolerance)
  end
  def can_donate?(_, _), do: false
end

defmodule WeightedRandom.Backend.WalkerAlias.Buckets do
  @moduledoc false
  alias __MODULE__.Sorter
  import Sorter

  @default_tolerance 1.0e-10

  def fill_all(sorter, tolerance \\ @default_tolerance) do
    if is_full?(sorter) do
      sorter
    else
      fill_next(sorter, tolerance)
        |> fill_all()
    end
  end

  def fill_next(sorter, tolerance \\ @default_tolerance) do
    with {:full, false} <- {:full, is_full?(sorter)},
         {:high_singlet, false} <- {:high_singlet, is_high_singlet?(sorter, tolerance)},
         {:low_singlet, false} <- {:low_singlet, is_low_singlet?(sorter, tolerance)},
         {:final_high, false} <- {:final_high, is_final_high?(sorter)},
         {:final_low, false} <- {:final_low, is_final_low?(sorter)}
    do
      donate(sorter, tolerance)
    else
      {:full, true} -> sorter
      {:high_singlet, true} -> add_higher_singlet(sorter)
      {:low_singlet, true} -> add_lower_singlet(sorter)
      {:final_high, true} -> add_higher_singlet(sorter)
      {:final_low, true} -> add_lower_singlet(sorter)
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

  defp add_depleted_higher(sorter, bucket, tolerance) do
    temp_sorter = add_higher(sorter, bucket)
    if can_donate?(temp_sorter, tolerance) do
      temp_sorter
    else
      add_lower(sorter, bucket)
    end
  end


end
