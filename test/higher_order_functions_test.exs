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
      result = func.(x)
      send self(), {
        String.to_atom(label),
        %{
          name: "#{inspect func}",
          called_with: [x],
          result: result
        }
      }
      result
    end
  end

  def spy_arity(2, func, label) do
    fn x, y ->
      result = func.(x, y)
      send self(), {
        String.to_atom(label),
        %{
          name: "#{inspect func}",
          called_with: [x, y],
          result: result
        }
      }
      result
    end
  end

  def spy_arity(3, func, label) do
    fn x, y, z ->
      result = func.(x, y, z)
      send self(), {
        String.to_atom(label),
        %{
          name: "#{inspect func}",
          called_with: [x, y, z],
          result: result
        }
      }
      result
    end
  end

  describe "our spy" do
    test "what does the spy get" do
      spied = spy_arity(2, &Enum.take/2, "taking")
      spied.([1, 2, 3], 1)

      receive do
        {:taking, message} ->
          assert Enum.at(message.called_with, 0) == [1, 2, 3]
        _ -> flunk()
      end
    end

    test "a 3 arity spy" do
      reducer = spy_arity(3, &Enum.reduce/3, "reducing")
      add = fn x, y -> x + y end

      assert reducer.([1, 2, 3], 0, add) == 6

      receive do
        {:reducing, message} ->
          assert message.called_with == [[1, 2, 3], 0, add]
          assert message.result == 6
        _ -> flunk()
      end
    end
  end

  describe "compose" do
    test "calls with spy" do
      sq = spy(&HigherOrderFunctions.square/1, "the square")
      cu = spy(&HigherOrderFunctions.cube/1, "the cube")
      func = HigherOrderFunctions.compose(cu, sq)

      func.(2)

      square_name = "#{inspect &HigherOrderFunctions.square/1}"
      cube_name = "#{inspect &HigherOrderFunctions.cube/1}"
      assert_received {:"the square", %{called_with: [2], name: ^square_name}}
      assert_received {:"the cube", %{called_with: [4], name: ^cube_name}}
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
end
