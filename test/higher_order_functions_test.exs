defmodule HigherOrderFunctionsTest do
  use ExUnit.Case
  doctest HigherOrderFunctions

  describe "compose" do
    test "calls right function first" do
      sq = fn x ->
        send self(), {:square, x}
        x * x
      end
      cu = fn x ->
        send self(), {:cube, x}
        x * x * x
      end

      func = HigherOrderFunctions.compose(cu, sq)

      assert func.(2) == 64
      {:messages, message} = :erlang.process_info(self(), :messages)

      assert message == [{:square, 2},{:cube, 4}]
    end
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end
