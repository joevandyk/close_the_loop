defmodule CloseTheLoop.Feedback.IssueUpdateInput do
  @moduledoc false

  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Feedback,
    data_layer: :embedded,
    authorizers: [Ash.Policy.Authorizer]

  actions do
    # A form-only action that performs real updates on other resources.
    create :submit do
      argument :status, :atom do
        allow_nil? true
        constraints one_of: [:new, :acknowledged, :in_progress, :fixed]
      end

      argument :comment_body, :string do
        allow_nil? true
        constraints trim?: true
      end

      change CloseTheLoop.Feedback.IssueUpdateInput.Changes.NormalizeAndValidate
      change CloseTheLoop.Feedback.IssueUpdateInput.Changes.PerformUpdates
    end
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end
end
