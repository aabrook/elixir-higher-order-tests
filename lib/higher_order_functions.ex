defmodule HigherOrderFunctions do
  @moduledoc """
  Documentation for HigherOrderFunctions.
  """

  @doc ~S"""
  iex> add_1 = fn x -> x + 1 end
  ...> add_2 = fn x -> x + 2 end
  ...> add_3 = HigherOrderFunctions.compose(add_1, add_2)
  ...> add_3.(10)
  13

  iex> logger = &IO.inspect/1
  ...> take_last = fn enum -> Enum.take(enum, -1) end
  ...> take_and_log_last = HigherOrderFunctions.compose(logger, take_last)
  ...> take_and_log_last.([1, 2, 3])
  [3]
  """
  def compose(f, g) do
    fn x ->
      f.(g.(x))
    end
  end

  def square(n) do
    n * n
  end

  def cube(n) do
    n * n * n
  end
end
