defmodule WeightedRandom.InputTest do
  use ExUnit.Case
  alias WeightedRandom.Input
  doctest Input


  describe "Input Add Weight" do
    test "neighbours right" do
      prob = Input.from_outcomes(1..100)
      weight = Input.Weight.new(%{
        target: 5,
        amount: 25,
        curve: :ease_in_cubic,
        right_dist: 10
      })
      prob = Input.add_weight(prob, weight)
      assert Input.at(prob, 5) == 26
      assert Input.at(prob, 6) |> Float.round(3) == 19.225
      assert Input.at(prob, 7) |> Float.round(3) == 13.8
      assert Input.at(prob, 4) == 1.0
    end
    test "neighbours left" do
      prob = Input.from_outcomes(1..100)
      weight = Input.Weight.new(%{
        target: 50,
        amount: 25,
        curve: :ease_in_cubic,
        left_dist: 10
      })
      prob = Input.add_weight(prob, weight)
      assert Input.at(prob, 50) == 26
      assert Input.at(prob, 51) == 1.0
      assert Input.at(prob, 49) |> Float.round(3) == 19.225
      assert Input.at(prob, 48) |> Float.round(3) == 13.8
    end
    test "radius" do
      prob = Input.from_outcomes(1..100)
      weight = Input.Weight.new(%{
        target: 50,
        amount: 25,
        curve: :ease_in_cubic,
        radius: 10
      })
      prob = Input.add_weight(prob, weight)
      assert Input.at(prob, 50) == 26
      assert Input.at(prob, 51) |> Float.round(3) == 19.225
      assert Input.at(prob, 49) |> Float.round(3) == 19.225
      assert Input.at(prob, 48) |> Float.round(3) == 13.8

    end
  end

  describe "Input conversion" do
    test "weights to probabilities" do
      prob = Input.from_outcomes(1..100)
      weight = Input.Weight.new(%{
        target: 50,
        amount: 25,
        curve: :ease_in_cubic,
        radius: 10
      })
      prob = Input.add_weight(prob, weight)

      probabilities = Input.weights_to_probabilities(prob)
      assert Float.round(Enum.sum(probabilities), 10) == 1.0
      assert Enum.count(probabilities) == 100
    end

    test "probabilities to weights" do
      prob = Input.from_outcomes(1..100)
      weight = Input.Weight.new(%{
        target: 50,
        amount: 25,
        curve: :ease_in_cubic,
        radius: 10
      })
      prob = Input.add_weight(prob, weight)

      probabilities = Input.weights_to_probabilities(prob)
      weights = Input.probabilities_to_weights(probabilities)

      # Due to floating point rounding weirdness, it often won't be *exactly* the same.
      # But getting within 10 decimal points is not the worst result in the world.
      old = Enum.map(prob.weights, &Float.round(&1, 10))
      new = Enum.map(weights, &Float.round(&1, 10))

      assert old == new
    end
  end


end
