defmodule WorldTracker.Repo do
  use Ecto.Repo,
    otp_app: :world_tracker,
    adapter: Ecto.Adapters.Postgres
end
