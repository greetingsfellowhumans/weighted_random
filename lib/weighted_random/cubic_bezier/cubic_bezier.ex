defmodule WeightedRandom.CubicBezier do
  # This module is deprecated and only exists to maintain backward compatibility.
  @moduledoc false

  @deprecated ~s"""
  Use the [Curves](https://hex.pm/packages/curves) library instead.
  """
  def solve(t, points, _opts \\ []) do
    curve = case points do
      atm when is_atom(atm) -> Curves.define_bezier(atm)
      {a, b, c, d} -> Curves.define_bezier([{0, 0}, {a, b}, {c, d}, {1, 1}])
    end
    {_, y} = Curves.solve!(curve, t)
    y
  end

end
