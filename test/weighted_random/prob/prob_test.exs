defmodule WeightedRandom.ProbTest do
  use ExUnit.Case
  alias WeightedRandom.Prob
  import Prob
  doctest Prob


  describe "Prob Add Weight" do
    test "neighbours right" do
      prob = Prob.new(1..100)
      weight = Prob.Weight.new(%{
        target: 5,
        amount: 25,
        curve: :ease_in_cubic,
        right_dist: 10
      })
      prob = Prob.add_weight(prob, weight)
      assert Prob.at(prob, 5) == 26
      assert Prob.at(prob, 6) |> Float.round(3) == 19.225
      assert Prob.at(prob, 7) |> Float.round(3) == 13.8
      assert Prob.at(prob, 4) == 1.0
    end
    test "neighbours left" do
      prob = Prob.new(1..100)
      weight = Prob.Weight.new(%{
        target: 50,
        amount: 25,
        curve: :ease_in_cubic,
        left_dist: 10
      })
      prob = Prob.add_weight(prob, weight)
      assert Prob.at(prob, 50) == 26
      assert Prob.at(prob, 51) == 1.0
      assert Prob.at(prob, 49) |> Float.round(3) == 19.225
      assert Prob.at(prob, 48) |> Float.round(3) == 13.8
    end
    test "radius" do
      prob = Prob.new(1..100)
      weight = Prob.Weight.new(%{
        target: 50,
        amount: 25,
        curve: :ease_in_cubic,
        radius: 10
      })
      prob = Prob.add_weight(prob, weight)
      assert Prob.at(prob, 50) == 26
      assert Prob.at(prob, 51) |> Float.round(3) == 19.225
      assert Prob.at(prob, 49) |> Float.round(3) == 19.225
      assert Prob.at(prob, 48) |> Float.round(3) == 13.8
    end
  end


end
