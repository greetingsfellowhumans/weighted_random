defmodule WeightedRandom.Dice.Opts do
  @moduledoc false

  @dice_new_body [
    modifier: [
      doc: "A number added or subtracted from the total. The modifier is applied only once, even with multiple dice.",
      required: false,
      type: :integer,
    ],
    dice: [
      doc: "A list of WeightedRandom.Die structs to make up the collection of dice. They can be any combination of sides and weights.",
      required: false,
      type: {:list, {:struct, WeightedRandom.Die}}
    ]
  ] |> NimbleOptions.new!()
  def dice_new_body_schema(), do: @dice_new_body
  def dice_new_body_docs(), do: @dice_new_body


  @die_new_body [
    sides: [
      doc: "The number of faces on a polyhedral die. This is used to generate 1-indexed outcomes",
      type: :pos_integer,
      default: 6,
    ],
    weights: [
      doc: "List of weights. See [details](WeightedRandom.html#module-customizing-weights).",
      type: {:list, {:custom, WeightedRandom.Input.Opts, :weights, []}},
      default: [],
    ]
  ]
  def die_new_body_schema(), do: @die_new_body
end
