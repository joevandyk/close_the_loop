defmodule CloseTheLoop.Messaging.OutboundDelivery do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Messaging,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "outbound_deliveries"
    repo CloseTheLoop.Repo

    # These indexes are for dev outbox style queries (newest first, filtered by channel/status/tenant).
    # If the DSL changes upstream, we'll still enforce indexes via generated migrations.
    custom_indexes do
      index [:channel, :inserted_at]
      index [:status, :inserted_at]
      index [:tenant, :inserted_at]
      index [:to]
    end
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [
        :channel,
        :status,
        :provider,
        :to,
        :from,
        :subject,
        :body,
        :tenant,
        :template,
        :related_resource,
        :related_id,
        :provider_id,
        :provider_response,
        :error
      ]
    end

    update :update do
      primary? true

      accept [
        :status,
        :provider_id,
        :provider_response,
        :error
      ]
    end
  end

  policies do
    # Access is restricted at the routing/UI layer (dev routes only for the outbox UI).
    # We keep this resource broadly accessible to enable recording from anywhere.
    policy always() do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :channel, :atom do
      allow_nil? false
      constraints one_of: [:sms, :email]
      public? true
    end

    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:queued, :sent, :failed, :noop]
      default :queued
      public? true
    end

    attribute :provider, :string do
      allow_nil? false
      constraints min_length: 1, trim?: true
      public? true
    end

    attribute :to, :string do
      allow_nil? false
      constraints min_length: 1, trim?: true
      public? true
    end

    attribute :from, :string do
      allow_nil? true
      constraints trim?: true
      public? true
    end

    attribute :subject, :string do
      allow_nil? true
      constraints trim?: true
      public? true
    end

    attribute :body, :string do
      allow_nil? false
      constraints min_length: 1
      sensitive? true
      public? false
    end

    attribute :tenant, :string do
      allow_nil? true
      constraints trim?: true
      public? true
    end

    attribute :template, :string do
      allow_nil? true
      constraints trim?: true
      public? true
    end

    attribute :related_resource, :string do
      allow_nil? true
      constraints trim?: true
      public? true
    end

    attribute :related_id, :uuid do
      allow_nil? true
      public? true
    end

    attribute :provider_id, :string do
      allow_nil? true
      constraints trim?: true
      public? true
    end

    attribute :provider_response, :map do
      allow_nil? true
      sensitive? true
      public? false
    end

    attribute :error, :string do
      allow_nil? true
      sensitive? true
      public? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end
end
