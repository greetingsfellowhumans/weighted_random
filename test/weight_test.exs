defmodule WeightedRandom.WeightTest do
  use ExUnit.Case
  alias WeightedRandom.Weight
  import Weight

  test "Weight struct gets list of affected neighbours" do
    weight = new(%{target: 10, weight: 10, radius: 3})
    [t8, t9, t11, t12] = create_side_effect_weights(weight)

    assert match?(%{target: 8, total_weight: 3}, t8)
    assert match?(%{target: 9, total_weight: 7}, t9)
    assert match?(%{target: 11, total_weight: 7}, t11)
    assert match?(%{target: 12, total_weight: 3}, t12)


    weight = new(%{target: 10, weight: 10, radius: 2})
    [t9, t11] = create_side_effect_weights(weight)

    assert match?(%{target: 9, total_weight: 5}, t9)
    assert match?(%{target: 11, total_weight: 5}, t11)


    weight = new(%{target: 10, weight: 5, radius: 3, curve: :ease_out})
    [t8, t9, t11, t12] = create_side_effect_weights(weight)

    assert match?(%{target: 8, total_weight: 1}, t8)
    assert match?(%{target: 9, total_weight: 3}, t9)
    assert match?(%{target: 11, total_weight: 3}, t11)
    assert match?(%{target: 12, total_weight: 1}, t12)


    weight = new(%{target: 10, weight: 5, radius: 3, curve: :ease_in})
    [t8, t9, t11, t12] = create_side_effect_weights(weight)

    assert match?(%{target: 8, total_weight: 2}, t8)
    assert match?(%{target: 9, total_weight: 4}, t9)
    assert match?(%{target: 11, total_weight: 4}, t11)
    assert match?(%{target: 12, total_weight: 2}, t12)
  end


  test "Calculates distance as a percentage" do
    assert 1.0 == distance_perc(10, 10, 20)
    assert 1.0 == distance_perc(10, 10, 0)
    assert 0.5 == distance_perc(10, 10, 5)
    assert 0.5 == distance_perc(10, 10, 15)
    assert 0.0 == distance_perc(10, 10, 10)
  end    

  test "Calculates weight effect" do
    t1 = 10
    t2 = 15
    r = 10
    w1 = 10

    expected = 0.5 * w1
    assert expected == weight_at_location(t1, t2, r, w1)

    t1 = 10
    t2 = 15
    r = 5
    w1 = 10

    expected = 0
    assert expected == weight_at_location(t1, t2, r, w1)


    t1 = 10
    t2 = 8
    r = 10
    w1 = 10

    assert 8 == weight_at_location(t1, t2, r, w1, :linear)
    assert 7 == weight_at_location(t1, t2, r, w1, :ease_out)

  end    


  test "Generates empty neighbours" do
    weight = new(%{target: 10, weight: 5, radius: 2})
    li = generate_empty_neighbours(weight)
         |> Enum.map(&(&1.target))
         |> Enum.sort()
    assert [8, 9, 11, 12] == li

  end

  test "split weight" do
    weight = new(%{target: 10, weight: 5, radius: 2})
    assert [10, 10, 10, 10, 10] == split(weight)
  end

  test "Bezier Curves" do
    range = 1..100
    weight = %{target: 100, weight: 100, radius: 100}
    take = 1000
    weight_in = Map.put(weight, :curve, :ease_in)
    weight_out = Map.put(weight, :curve, :ease_out)

    :rand.seed(:exsss, {100, 101, 102})
    ease_in = Stream.repeatedly(fn -> WeightedRandom.rand(range, weight_in, index: false) end) |> Enum.take(take)
      |> parse_curve()

    :rand.seed(:exsss, {100, 101, 102})
    ease_out = Stream.repeatedly(fn -> WeightedRandom.rand(range, weight_out, index: false) end) |> Enum.take(take)
      |> parse_curve()
    

    zips = zip_curves(ease_in, ease_out, range)
    first_half = Enum.take(zips, 50) |> Enum.frequencies()
    last_half = Enum.take(zips, -50) |> Enum.frequencies()

    # I would expect an ease_in to be heavier on the low end, and ease_out to be heavier on the high end.
    assert first_half.ease_in > first_half.ease_out # 39 to 5
    assert last_half.ease_in < last_half.ease_out # 33 to 16


  end

  defp zip_curves(li1, li2, range) do
    Enum.map(range, fn n ->
      in_count = Enum.find_value(li1, fn %{n: ln, count: count} -> if n == ln, do: count end) || 0
      out_count = Enum.find_value(li2, fn %{n: ln, count: count} -> if n == ln, do: count end) || 0
      cond do
        in_count > out_count -> :ease_in
        in_count < out_count -> :ease_out
        true -> :eq
      end
    end)
  end

  defp parse_curve(li) do
    li
      |> Enum.frequencies_by(&(&1))
      |> Enum.sort_by(fn {_n, count} -> count end)
      |> Enum.map(fn {n, count} ->
      %{n: n, count: count, prod: n * count}
    end)
  end

  test "non integers" do
    :rand.seed(:exsss, {100, 101, 102})
    idx = 10
    alpha = "abcdefghijklmnopqrstuvwxyz"
    range = String.split(alpha, "", trim: true)
    top_result = Stream.repeatedly(fn -> WeightedRandom.rand(range, %{target: idx, weight: 10}) end) |> Enum.take(10)
      |> Enum.frequencies()
      |> Enum.sort_by(fn {_, c} ->  c end, :desc)
      |> List.first()
      |> elem(0)
    assert top_result == String.at(alpha, idx)
  end

end
