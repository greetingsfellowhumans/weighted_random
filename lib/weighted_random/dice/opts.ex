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
end
