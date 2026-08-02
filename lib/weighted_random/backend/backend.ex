defmodule WeightedRandom.Backend do
  @moduledoc ~s"""
  WeightedRandom.Backend offers a contract to all who implement it:
  1. The main WeightedRandom package presents a novel interface for generating a list of weights.
  2. The custom Backend module exposes the discrete probability distribution algorithm.
  """

  @callback preprocess(weights :: list(float()), opts :: keyword()) :: table :: struct()
  @callback take(table :: struct(), count :: integer()) :: struct()

  def preprocess(backend, weights, opts) do
    backend.preprocess(weights, opts)
  end
  def take(backend, table, count) do
    backend.take(table, count)
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour WeightedRandom.Backend
      
    end
  end
end
