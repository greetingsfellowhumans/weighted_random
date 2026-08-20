defmodule WeightedRandom.Utils.Crypto do
  @moduledoc ~s"""
  Based on this [blog post](https://hashrocket.com/blog/posts/the-adventures-of-generating-random-numbers-in-erlang-and-elixir)
  run `reseed`, to generate a cryptographically secure seed for your random number generators.

  I would actually suggest *every* elixir app should call this function at the beginning of it's startup process, even if the `WeightedRandom` library is not being used.

  ## Usage
  ```elixir
  # my_app/lib/my_app/application.ex
  defmodule MyApp.Application do
    use Application

    @impl true
    def start(_type, _args) do
      WeightedRandom.Utils.Crypto.reseed()
      children = [
        ...
      ]
      opts = [...]
      Supervisor.start_link(children, opts)
    end
  end
  ```
  """

  def reseed() do
    <<a :: unsigned-integer-32, b :: unsigned-integer-32, c :: unsigned-integer-32>> = :crypto.strong_rand_bytes(12)
    :rand.seed(:exsplus, {a, b, c})
  end
end
