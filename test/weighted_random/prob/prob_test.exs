defmodule WeightedRandom.ProbTest do
  use ExUnit.Case
  alias WeightedRandom.Prob
  import Prob
  doctest Prob


  describe "Prob" do
    test "create the Prob tensor" do
      prob = Prob.new(1..100)
      prob = Prob.add_weight(prob, 5, 25)
      assert Prob.at(prob, 5) == 26
    end
  end


end
