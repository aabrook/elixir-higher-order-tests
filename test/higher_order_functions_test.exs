defmodule HigherOrderFunctionsTest do
  use ExUnit.Case
  doctest HigherOrderFunctions

  def square(n) do
    send self(), {:square, n}
    n * n
  end

  def cube(n) do
    send self(), {:cube, n}
    n * n * n
  end

  describe "compose" do
    test "calls right function first" do
      func = HigherOrderFunctions.compose(&cube/1, &square/1)

      assert func.(2) == 64
      {:messages, message} = :erlang.process_info(self(), :messages)

      assert message == [{:square, 2},{:cube, 4}]
    end
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end
