defmodule WeightedRandom.Backends.Walker2.SorterTest do
  use ExUnit.Case
  use ExUnitProperties
  alias WeightedRandom.Backend.WalkerAlias2, as: Mod
  alias Mod.Buckets.Sorter
  alias WeightedRandom.Utils.Analysis

  @sample_probs [
    [0.1, 0.2, 0.2, 0.5],
    [1.0],
    [0.5, 0.5],
    [0.3, 0.3, 0.1]
  ]
  def probs_to_sorter(probs) do
    {l, h, m} = Mod.Preprocess.prep_numbers(probs)
    Sorter.new(l, h, m)
  end
  #describe "Sorter" do
  #  test "ascending list" do
  #    opts = []
  #    sorter = probs_to_sorter([0.1, 0.2, 0.2, 0.5])

  #    sorter0 = %Sorter{
  #      bucket_size: 0.25,
  #      lowers: [{0.1, 0}, {0.2, 1}, {0.2, 2}],
  #      highers: [{0.5, 3}],
  #      buckets: []
  #    } |> Mod.Buckets.handle_singlets(opts)
  #    assert sorter == sorter0

  #    sorter1 = %Sorter{
  #      bucket_size: 0.25,
  #      lowers: [{0.2, 1}, {0.2, 2}],
  #      highers: [{0.35, 3}],
  #      buckets: [{0.1, 0, 3}]
  #    } |> Mod.Buckets.handle_singlets(opts)

  #    assert Mod.Buckets.fill(sorter0) == sorter1

  #    sorter2 = %Sorter{
  #      bucket_size: 0.25,
  #      lowers: [{0.2, 2}],
  #      highers: [{0.3, 3}],
  #      buckets: [{0.2, 1, 3}, {0.1, 0, 3}]
  #    } |> Mod.Buckets.handle_singlets(opts)

  #    assert Mod.Buckets.fill(sorter1) == sorter2

  #    sorter3 = %Sorter{
  #      bucket_size: 0.25,
  #      lowers: [],
  #      highers: [{0.25, 3}],
  #      buckets: [{0.2, 2, 3}, {0.2, 1, 3}, {0.1, 0, 3}]
  #    }

  #    assert Mod.Buckets.fill(sorter2) == sorter3

  #    sorter4 = %Sorter{
  #      bucket_size: 0.25,
  #      lowers: [],
  #      highers: [],
  #      buckets: [{0.0, 3, 3}, {0.2, 2, 3}, {0.2, 1, 3}, {0.1, 0, 3}]
  #    }
  #    assert Mod.Buckets.handle_singlets(sorter3, opts) == sorter4

  #    assert Mod.Buckets.fill_while(sorter0) == sorter4
  #  end
  #  test "single value" do
  #    sorter = probs_to_sorter([1.0])

  #    sorter0 = %Sorter{
  #      bucket_size: 1,
  #      lowers: [],
  #      highers: [{1.0, 0}],
  #      buckets: []
  #    }
  #    assert sorter == sorter0
  #    assert Mod.Buckets.fill_while(sorter).buckets == [{0.0, 0, 0}]
  #  end

  #  test "descending list" do
  #    sorter = probs_to_sorter([0.5, 0.25, 0.2, 0.5])

  #    sorter0 = %Sorter{
  #      bucket_size: 0.3625,
  #      lowers: [{0.2, 2}, {0.25, 1}],
  #      highers: [{0.5, 3}, {0.5, 0}],
  #      buckets: []
  #    }
  #    assert sorter == sorter0

  #    sorter = Mod.Buckets.fill_while(sorter)
  #    assert sorter.buckets == [{0.0, 0, 0}, {0.22500000000000003, 3, 0}, {0.25, 1, 3}, {0.2, 2, 3}]
  #  end
  #  test "equal" do
  #    sorter = probs_to_sorter([0.01, 0.01])

  #    sorter0 = %Sorter{
  #      bucket_size: 0.01,
  #      lowers: [],
  #      highers: [{0.01, 1}, {0.01, 0}],
  #      buckets: []
  #    }
  #    assert sorter == sorter0

  #    sorter = Mod.Buckets.fill_while(sorter)
  #    assert sorter.buckets == [{0.0, 0, 0}, {0.0, 1, 1}]
  #  end
  #  test "obscure bug" do
  #    probs = [0.29129181217368993, 0.5148269290369397, 0.07757903329874216, 0.8485666817418479, 0.12125, 0.783912959922003, 0.24112666918779724, 0.7519803084965885, 0.07605468750000001, 0.428798031199597, 0.03432596445083618, 0.6274189161517395, 0.8854011535644531, 0.4085009765625, 0.8182266923885202, 0.072578125, 0.9, 0.08122846819271415, 0.8010126112297986, 0.6927882870152569, 0.6684796295597056, 0.7969851344839834, 0.8964124338004749, 0.25457451137998716, 0.7412892400931463, 0.63751953125, 0.78875, 0.7050952148437499, 0.6287389511915007, 0.21727728357654996, 0.4013594106072037, 0.15054330565446292, 0.27941318568961393, 0.3521969604492188, 0.1716015823811176, 0.8177444309680739, 0.35396240234375004, 0.4854657554626465, 0.44428426544251265, 0.7651127985835775, 0.8745463296210891, 0.02390625, 0.109815945753034, 0.8759993432599514, 0.48774958618836534, 0.7755815258222232, 0.23680273569072596, 0.2511381144769257, 0.2920659750983741, 0.2349084337408637, 0.14401571273803712, 0.795969311130244, 0.2726410063743892, 0.29629708698485047, 0.6658550991117954, 0.5755629951726919, 0.6373239591374016, 0.596115064918995, 0.6775, 0.7055096901654111, 0.11958273846448517, 0.5239103260888986, 0.5426744180682025, 0.47013939502106156, 0.40123327156787164, 0.239453125, 0.50562744140625, 0.5284318832580175, 0.429977623322735, 0.5698062605087761, 0.034268519936149856, 0.49474550779833326, 0.6381683350329163, 0.3119245147705078, 0.11125488281250001, 0.4312615966796875, 0.3696688685168533, 0.4212911981144521]
  #            |> WeightedRandom.Input.Normalize.normalize_probabilities()

  #    sorter = probs_to_sorter(probs)

  #    sorter = Mod.Buckets.fill_while(sorter, tolerance: 0.0000000000000001)
  #    #assert sorter == sorter0

  #    #sorter = Mod.Buckets.fill_while(sorter)
  #    #assert sorter.buckets == [{0.0, 0, 0}, {0.0, 1, 1}]
  #  end

  #end

  #describe "Preprocess" do
  #  property "Split the probabilities" do
  #    check all floats <- StreamData.list_of(StreamData.float(min: 0.01, max: 0.9), min_length: 1) do
  #      probabilities = WeightedRandom.Input.Normalize.normalize_probabilities(floats)
  #                      |> Enum.map(&(Float.round(&1, 4)))

  #      opts = [backend: Mod]
  #      %{table: table} = WeightedRandom.preprocess_p(probabilities, opts)
  #      assert is_struct(table, Mod.Table)
  #      assert Enum.count(probabilities) == Enum.count(table.buckets)

  #    end
  #  end
  #end



end

