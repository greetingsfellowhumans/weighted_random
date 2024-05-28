defmodule WeightedRandom.CubicBezier do
  @moduledoc """
  Copied from https://github.com/bjunc/cubic-bezier/tree/master
  Unfortunately the build seems to be broken so I could not use it directly.
  """


  # Duration value to use when one is not specified 
  # 400ms is a common value
  @default_duration 400
  

  # The epsilon value we pass to UnitBezier::solve given that the animation 
  # is going to run over |dur| seconds.

  # The longer the animation, the more precision we need in the timing function 
  # result to avoid ugly discontinuities.

	# http://svn.webkit.org/repository/webkit/trunk/Source/WebCore/page/animation/AnimationBase.cpp
  defp solve_epsilon(duration) do
    1.0 / (200.0 * duration)
  end


  # Defines a cubic-bezier curve given the middle two control points.
	# NOTE: first and last control points are implicitly (0,0) and (1,1).
  # 
  # `p1x` is the `X` component of control point `1`  
	# `p1y` is the `Y` component of control point `1`  
	# `p2x` is the `X` component of control point `2`  
	# `p2y` is the `Y` component of control point `2`  
  @spec calculate_coefficients(tuple) :: tuple
  defp calculate_coefficients({p1x, p1y, p2x, p2y}) do
    # Calculate the polynomial coefficients
    # Implicit first and last control points are (0,0) and (1,1).

    # X component of Bezier coefficient C
		cx = 3.0 * p1x

    # X component of Bezier coefficient B
		bx = 3.0 * (p2x - p1x) - cx

    # X component of Bezier coefficient A
		ax = 1.0 - cx - bx

    # Y component of Bezier coefficient C
		cy = 3.0 * p1y

    # Y component of Bezier coefficient B
		by = 3.0 * (p2y - p1y) - cy

		# Y component of Bezier coefficient A
    ay = 1.0 - cy - by
    
    {ax, bx, cx, ay, by, cy}
  end


  
  #`t` is the parametric timing value
  @spec sample_curve_x(float, tuple) :: float
  defp sample_curve_x(t, {ax, bx, cx, _ay, _by, _cy}) do
    # `ax t^3 + bx t^2 + cx t' expanded using Horner's rule.
    ((ax * t + bx) * t + cx) * t
  end

    
  # `t` is the parametric timing value.
  @spec sample_curve_y(float, tuple) :: float
  defp sample_curve_y(t, {_ax, _bx, _cx, ay, by, cy}) do
    ((ay * t + by) * t + cy) * t
  end


  # `t` is the parametric timing value.
  @spec sample_curve_derivative_x(float, tuple) :: float
  defp sample_curve_derivative_x(t, {ax, bx, cx, _ay, _by, _cy}) do
    (3.0 * ax * t + 2.0 * bx) * t + cx
  end


  # Given an x value, find a parametric value it came from.

  # The `x` is the value of `x` along the bezier curve, `0.0 <= x <= 1.0`
  
	# The `epsilon` is the accuracy limit of `t` for the given `x`
  @spec solve_curve_x(float, float, tuple) :: float
  defp solve_curve_x(x, epsilon, coefficients) do
    t2 = x

    t2 =
      Enum.reduce_while(Enum.to_list(1..8), t2, fn (_i, t2) ->
        x2 = sample_curve_x(t2, coefficients) - x

        if abs(x2) < epsilon do
					{:halt, t2}
        else
          d2 = sample_curve_derivative_x(t2, coefficients) 
          if abs(d2) < :math.exp(-6),
            do: {:halt, nil},
            else: {:cont, t2 - x2 / d2}
        end
      end)

    if t2 != nil do
      t2
    else
      IO.puts "COULD NOT SOLVE CURVE X"
      x

      # TODO: convert to Elixir code as fall-back
      # Fall back to the bisection method for reliability.
      # t0 = 0.0;
      # t1 = 1.0;
      # t2 = x;

      # if (t2 < t0) {
      #   return t0;
      # }
      # if (t2 > t1) {
      #   return t1;
      # }

      # while (t0 < t1) {
      #   x2 = sampleCurveX(t2);
      #   if (Math.abs(x2 - x) < epsilon) {
      #     return t2;
      #   }
      #   if (x > x2) {
      #     t0 = t2;
      #   } else {
      #     t1 = t2;
      #   }
      #   t2 = (t1 - t0) * 0.5 + t0;
      # }

      # # Failure.
      # return t2;
    end
  end

    
  # Returns the y value along the bezier curve.
  
  # `x` is the value of x along the bezier curve, `0.0 <= x <= 1.0`

  # `epsilon` is the accuracy of `t` for the given `x`.
  @spec solve_with_epsilon(float, float, tuple) :: float
  defp solve_with_epsilon(x, epsilon, coefficients) do
    sample_curve_y(solve_curve_x(x, epsilon, coefficients), coefficients)
  end


  @doc """
  Given `x` (a float between `0.0` and `1.0`), compute the `y`. 

  Either an easing atom or control points tuple can be provided.  
  Most common easing equations are support, but if an unsupported atom 
  is given, the control points for `:linear` are returned.

  See: https://gist.github.com/terkel/4377409

  ## Options

  - `duration` (integer) - can provide greater accuracy.  
  The default duration is 400 (ms), which is a common animation / transition duration.

  ## Examples

  ```elixir
  iex> WeightedRandom.CubicBezier.solve(0.50, :ease_out_quad)
  0.7713235628639843
  ```

  ```elixir
  iex> WeightedRandom.CubicBezier.solve(0.5, {0.250,  0.460,  0.450,  0.940})
  0.7713235628639843
  ```

  ```elixir
  iex(1)> Enum.map([0.0, 0.25, 0.5, 0.75, 1.0], fn x -> 
  ...(1)> {x, Float.round(WeightedRandom.CubicBezier.solve(x, :ease_out_quad), 3)}
  ...(1)> end)
  [{0.0, 0.0}, {0.25, 0.453}, {0.5, 0.771}, {0.75, 0.936}, {1.0, 1.0}]
  ```
  """
  @spec solve(float, atom | tuple, list) :: float
  def solve(x, easing_or_control_points, opts \\ [])
  when is_float(x) and is_list(opts) do
    control_points =
      case easing_or_control_points do
        easing when is_atom(easing) -> control_points(easing)
        control_points when is_tuple(control_points) -> control_points
      end
    
    # solve(x, control_points, opts)
    duration = Keyword.get(opts, :duration, @default_duration)
    coefficients = calculate_coefficients(control_points)
    solve_with_epsilon(x, solve_epsilon(duration), coefficients)
  end


  # Return a control points tuple based on 
  # the easing equation name. 
  @spec control_points(atom) :: tuple
  defp control_points(atom) when is_atom(atom) do
    easing = %{
      linear:             {0.250,  0.250,  0.750,  0.750},
      ease:               {0.250,  0.100,  0.250,  1.000},
      ease_in:            {0.420,  0.000,  1.000,  1.000},
      ease_out:           {0.000,  0.000,  0.580,  1.000},
      ease_in_out:        {0.420,  0.000,  0.580,  1.000},

      ease_in_quad:       {0.550,  0.085,  0.680,  0.530},
      ease_in_cubic:      {0.550,  0.055,  0.675,  0.190},
      ease_in_quart:      {0.895,  0.030,  0.685,  0.220},
      ease_in_quint:      {0.755,  0.050,  0.855,  0.060},
      ease_in_sine:       {0.470,  0.000,  0.745,  0.715},
      ease_in_expo:       {0.950,  0.050,  0.795,  0.035},
      ease_in_circ:       {0.600,  0.040,  0.980,  0.335},
      ease_in_back:       {0.600, -0.280,  0.735,  0.045},

      ease_out_quad:      {0.250,  0.460,  0.450,  0.940},
      ease_out_cubic:     {0.215,  0.610,  0.355,  1.000},
      ease_out_quart:     {0.165,  0.840,  0.440,  1.000},
      ease_out_quint:     {0.230,  1.000,  0.320,  1.000},
      ease_out_sine:      {0.390,  0.575,  0.565,  1.000},
      ease_out_expo:      {0.190,  1.000,  0.220,  1.000},
      ease_out_circ:      {0.075,  0.820,  0.165,  1.000},
      ease_out_back:      {0.175,  0.885,  0.320,  1.275},

      ease_in_out_quad:   {0.455,  0.030,  0.515,  0.955},
      ease_in_out_cubic:  {0.645,  0.045,  0.355,  1.000},
      ease_in_out_quart:  {0.770,  0.000,  0.175,  1.000},
      ease_in_out_quint:  {0.860,  0.000,  0.070,  1.000},
      ease_in_out_sine:   {0.445,  0.050,  0.550,  0.950},
      ease_in_out_expo:   {1.000,  0.000,  0.000,  1.000},
      ease_in_out_circ:   {0.785,  0.135,  0.150,  0.860},
      ease_in_out_back:   {0.680, -0.550,  0.265,  1.550}
    }
    
    Map.get(easing, atom, easing.linear)
  end
end

