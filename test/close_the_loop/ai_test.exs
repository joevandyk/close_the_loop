defmodule CloseTheLoop.AITest do
  use ExUnit.Case, async: false

  alias CloseTheLoop.AI

  test "categorize_issue/1 errors when OPENAI_API_KEY missing" do
    prev = System.get_env("OPENAI_API_KEY")

    on_exit(fn ->
      if is_nil(prev),
        do: System.delete_env("OPENAI_API_KEY"),
        else: System.put_env("OPENAI_API_KEY", prev)
    end)

    System.delete_env("OPENAI_API_KEY")

    assert {:error, :missing_openai_api_key} = AI.categorize_issue("The shower is cold")
  end
end
