defmodule CloseTheLoopWeb.QRCode do
  @moduledoc false

  @spec svg_data_uri(String.t()) :: String.t() | nil
  def svg_data_uri(text) when is_binary(text) do
    case text |> QRCode.create(:medium) |> QRCode.render(:svg) do
      {:ok, rendered} ->
        svg = IO.iodata_to_binary(rendered)
        "data:image/svg+xml;base64," <> Base.encode64(svg)

      _ ->
        nil
    end
  end
end
