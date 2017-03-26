defmodule HigherOrderFunctions do
  @moduledoc """
  Documentation for HigherOrderFunctions.
  """

  def compose(f, g) do
    fn x ->
      f.(g.(x))
    end
  end

  @doc """
  Hello world.

  ## Examples

      iex> HigherOrderFunctions.hello
      :world

  """
  def hello do
    :world
  end
end
