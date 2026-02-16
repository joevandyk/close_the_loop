defmodule CloseTheLoop.TestHelpers do
  @moduledoc false

  def unique_email(prefix \\ "user") do
    "#{prefix}-#{System.unique_integer([:positive])}@example.com"
  end
end
