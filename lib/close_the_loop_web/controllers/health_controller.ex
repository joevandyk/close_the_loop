# lib/close_the_loop_web/controllers/health_controller.ex
defmodule CloseTheLoopWeb.HealthController do
  use CloseTheLoopWeb, :controller

  def health(conn, _params) do
    json(conn, %{status: "ok"})
  end

  def ready(conn, _params) do
    # 
    case Ecto.Adapters.SQL.query(CloseTheLoop.Repo, "SELECT 1") do
      {:ok, _} ->
        json(conn, %{status: "ready"})

      {:error, _} ->
        conn
        |> put_status(503)
        |> json(%{status: "not ready", error: "Database connection failed"})
    end

    # 
  end

  def version(conn, _params) do
    json(conn, %{
      version: Application.get_env(:close_the_loop, :app_version, "dev"),
      sha: Application.get_env(:close_the_loop, :git_sha, "unknown"),
      app: "close-the-loop",
      env: Application.get_env(:close_the_loop, :app_env, "local")
    })
  end
end
