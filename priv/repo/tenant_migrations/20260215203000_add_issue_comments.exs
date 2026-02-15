defmodule CloseTheLoop.Repo.TenantMigrations.AddIssueComments do
  @moduledoc """
  Adds internal-only comments on issues.
  """

  use Ecto.Migration

  def up do
    create table(:issue_comments, primary_key: false, prefix: prefix()) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :body, :text, null: false

      # Users live in the public schema; store identifiers without FK constraints.
      add :author_user_id, :uuid
      add :author_email, :text

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :issue_id,
          references(:issues,
            column: :id,
            name: "issue_comments_issue_id_fkey",
            type: :uuid,
            prefix: prefix()
          ),
          null: false
    end

    create index(:issue_comments, [:issue_id], prefix: prefix())
    create index(:issue_comments, [:issue_id, :inserted_at], prefix: prefix())
  end

  def down do
    drop_if_exists index(:issue_comments, [:issue_id, :inserted_at], prefix: prefix())
    drop_if_exists index(:issue_comments, [:issue_id], prefix: prefix())

    drop constraint(:issue_comments, "issue_comments_issue_id_fkey")
    drop table(:issue_comments, prefix: prefix())
  end
end

