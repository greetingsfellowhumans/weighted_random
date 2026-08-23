defmodule WeightedRandom.Backend.Opts do
  @moduledoc false

  @default_backend WeightedRandom.Backend.WalkerAlias

  @backend [
    doc: ~s"""
    Any module which implements the @behaviour: `WeightedRandom.Backend`.
    This is the core algorithm providing the randomness functionality.
    """,
    required: true,
    type: :atom,
  ]

  def backend(required? \\ true), do: Keyword.put(@backend, :required, required?)

  # Takes the first backend module found, checking in order:
  # 1. opts passed in
  # 2. Application config file
  # 3. default (WalkerAlias)
  def get_backend(opts) do
    if direct = opts[:backend] do
      direct
    else
      case Application.fetch_env(:weighted_random, :backend) do
        {:ok, b} -> b
        _ -> @default_backend
      end
    end
  end

  def add_backend(opts) do
    backend = get_backend(opts)
    Keyword.put(opts, :backend, backend)
  end

end

