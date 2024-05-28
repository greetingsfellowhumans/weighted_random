defmodule WeightedRandom.WeightTest do
  use ExUnit.Case
  alias WeightedRandom.Weight
  import Weight

  test "Weight struct gets list of affected neighbours" do
    weight = new(%{target: 10, weight: 5, radius: 3})
    [t8, t9, t11, t12] = create_side_effect_weights(weight)

    assert match?(%{target: 8, total_weight: 2}, t8)
    assert match?(%{target: 9, total_weight: 3}, t9)
    assert match?(%{target: 11, total_weight: 3}, t11)
    assert match?(%{target: 12, total_weight: 2}, t12)


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


end
