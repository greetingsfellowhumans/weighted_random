defmodule WeightedRandom.Utils.Opts do
  @moduledoc false
  @config_opts [
    #float_dtype: %{default: 16, doc: "The default bitsize for floats.", one_of: [8, 16, 32, 64]},
    #force_percent: %{default: false, doc: "If true, all results from `take` and `solve` are normalized as percentages of the max `y` coordinate defined ", one_of: [true, false]}
  ]

  _todo = ~s"""
  @TODO auto generate docs for all the config options
  """

  def merge_opts(user_opts, default_opts \\ [])
      when is_list(user_opts) and is_list(default_opts) do
    default_opts
    |> Keyword.merge(config_opts())
    |> Keyword.merge(user_opts)
  end

  defp config_opts() do
    Enum.map(@config_opts, fn {k, %{default: d}} ->
      o =
        case Application.fetch_env(:weighted_random, k) do
          {:ok, c} -> c
          :error -> d
        end

      {k, o}
    end)
  end
end
