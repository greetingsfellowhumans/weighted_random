defmodule WeightedRandom.Backend.WalkerAlias2.Buckets do
  alias WeightedRandom.Backend.WalkerAlias2.Types, as: BackendT
  alias WeightedRandom.Utils.Types, as: T


  @doc ~s"""
  Create buckets in a list.
  Every 'bucket' is a tuple of `{split_point, lower_index, higher_index}`
  """
  #@spec fill_buckets(lower :: T.indexed_probabilities(), upper :: T.indexed_probabilities(), bucket_size :: float()) :: list(BackendT.bucket())
  def fill_buckets(lower, higher, bucket_size) do
    fill_buckets(lower, higher, bucket_size, [])
  end

  # Here the lower probability, which is guaranteed to be below the bucket size, starts the bucket
  # One of the higher probabilities donates some of it's probability, filling the remainder
  def fill_buckets([], [], _, buckets), do: buckets
  def fill_buckets([{lp, li} | lower], [{hp, hi} | higher], bucket_size, buckets) do
    bucket = {lp, li, hi}
    new_high = {hp - lp, hi}
    case new_high do
      # High had the exact amount and is all used up now.
      {new_hp, _hi} when new_hp == 0.0 -> fill_buckets(lower, higher, bucket_size, [bucket | buckets])

      # high didn't have enough. Move it to the lowers, and dump out this bucket.
      {new_hp, hi} when new_hp < 0.0 -> fill_buckets([{hp, hi}, {lp, li} | lower], higher, bucket_size, buckets)

      # High had some leftover after donating...
      {new_hp, _hi} when new_hp > 0.0 -> 
        if new_hp > bucket_size do
          # ...Enough that it is still overweight
          fill_buckets(lower, [new_high | higher], bucket_size, [bucket | buckets])
        else
          # ...But it is now underweight
          fill_buckets([new_high | lower], higher, bucket_size, [bucket | buckets])
        end
    end
  end
  def fill_buckets([], [{hp, hi} | higher], bucket_size, buckets) when hp < bucket_size do
    fill_buckets([{hp, hi}], higher, bucket_size, buckets)
  end
  def fill_buckets([], [{hp, hi} | higher], bucket_size, buckets) when hp == bucket_size do
    fill_buckets([], higher, bucket_size, [{0.0, hi, hi} | buckets])
  end
  def fill_buckets([], [{hp, hi} | higher], bucket_size, buckets) when hp > bucket_size do
    fill_buckets([], [{hp - bucket_size, hi} | higher], bucket_size, [{0.0, hi, hi} | buckets])
  end
  def fill_buckets(lower, [], size, buckets) do
    dbg({"remaining lower than #{size}", lower})
    buckets
  end



end

