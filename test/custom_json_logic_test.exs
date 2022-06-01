defmodule CustomError do
  defexception [:message]
end

defmodule CustomJsonLogic do
  use JsonLogic.Base,
    operations: %{
      "plus" => :plus,
      "throw" => :throw
    }

  def plus([a, b], _), do: a + b

  def throw(data, _) do
    raise CustomError, message: data
  end
end

defmodule CustomJsonLogicTest do
  use ExUnit.Case

  test "plus operation exist and works" do
    assert CustomJsonLogic.apply(%{"plus" => [2, 3]}) == 5
  end

  test "nested apply/2 should use custom operations as well" do
    logic = %{
      "if" => [
        %{"===" => [%{"var" => "query.op"}, "get"]},
        %{"throw" => "E_NOT_FOUND"}
      ]
    }

    data = %{"query" => %{"op" => "get"}}

    assert_raise CustomError, fn ->
      CustomJsonLogic.apply(logic, data)
    end
  end
end
