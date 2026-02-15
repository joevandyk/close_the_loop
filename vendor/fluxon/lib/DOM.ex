defmodule Fluxon.DOM do
  @moduledoc false

  def gen_id do
    id =
      :crypto.strong_rand_bytes(16)
      |> Base.url_encode64()
      |> binary_part(0, 16)

    "flx_" <> id
  end
end
