defmodule CloseTheLoop.Repo.Migrations.AddUserNameToUsers do
  @moduledoc """
  Adds an optional display name for users.
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      add :name, :text
    end
  end

  def down do
    alter table(:users) do
      remove :name
    end
  end
end
