defmodule WeightedRandom.ProbTest do
  use ExUnit.Case
  alias WeightedRandom.Prob
  import Prob
  doctest Prob


  describe "Prob" do
    test "create the Prob tensor" do
      prob = Prob.new(1..100)
      target = 5
      amount = 25
      weight = Prob.Weight.new(%{
        target: 5,
        amount: 25,
        curve: :ease_in_cubic,
        right_dist: 10
      })
      prob = Prob.add_weight(prob, weight)
      assert Prob.at(prob, 5) == 26
      assert Prob.at(prob, 6) |> Float.round(3) == 19.225
      assert Prob.at(prob, 4) == 1.0
    end
  end


end
