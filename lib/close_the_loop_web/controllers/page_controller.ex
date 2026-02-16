defmodule CloseTheLoopWeb.PageController do
  use CloseTheLoopWeb, :controller

  def home(conn, _params) do
    conn
    |> assign(:page_title, "CloseTheLoop")
    |> assign(
      :page_description,
      "QR + SMS issue intake. Let customers report problems in seconds - and automatically close the loop."
    )
    |> render(:home)
  end

  def how_it_works(conn, _params) do
    conn
    |> assign(:page_title, "How it works")
    |> assign(
      :page_description,
      "A simple flow: QR -> report -> inbox triage -> updates to opted-in reporters."
    )
    |> render(:how_it_works)
  end

  def pricing(conn, _params) do
    conn
    |> assign(:page_title, "Pricing")
    |> assign(:page_description, "Simple pricing for businesses with real-world locations.")
    |> render(:pricing)
  end

  def privacy(conn, _params) do
    conn
    |> assign(:page_title, "Privacy")
    |> assign(:page_description, "Privacy policy.")
    |> render(:privacy)
  end

  def terms(conn, _params) do
    conn
    |> assign(:page_title, "Terms")
    |> assign(:page_description, "Terms of service.")
    |> render(:terms)
  end
end
