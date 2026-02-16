defmodule CloseTheLoop.Events.Event do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshEvents.EventLog]

  postgres do
    table "events"
    repo CloseTheLoop.Repo
  end

  event_log do
    advisory_lock_key_generator(CloseTheLoop.Events.AdvisoryLockKeyGenerator)

    # Attribute the event to signed-in users when actor is a User resource.
    persist_actor_primary_key(:user_id, CloseTheLoop.Accounts.User)
  end

  actions do
    defaults [:read]
  end

  multitenancy do
    # Store events per-tenant (each organization has its own Postgres schema).
    strategy :context
  end
end
