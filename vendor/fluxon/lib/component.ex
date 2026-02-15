defmodule Fluxon.Component do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component

      import Fluxon.ClassMerge, only: [merge: 1]
      import Fluxon.DOM, only: [gen_id: 0]
      import Fluxon.Translate, only: [translate: 1]
    end
  end
end
