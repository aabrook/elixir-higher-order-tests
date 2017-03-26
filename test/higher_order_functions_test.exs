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

  def spy(func, label) do
    fn x ->
      send self(), {
        String.to_atom(label),
        %{
          name: "#{inspect func}",
          arg: "#{inspect x}"
        }
      }
      func.(x)
    end
  end

  describe "compose" do
    test "calls with spy" do
      sq = spy(&HigherOrderFunctions.square/1, "the square")
      cu = spy(&HigherOrderFunctions.cube/1, "the cube")
      func = HigherOrderFunctions.compose(cu, sq)

      func.(2)
      IO.inspect :erlang.process_info(self(), :messages)

    end

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

    test "calls func with functions" do
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
