# Locations Overpass Worker

`WorldTracker.Workers.Locations` ingests global location data from Overpass API once per day and stores it in the `locations` table.

## What it collects

The worker fetches these location types worldwide:

- `:data_center`
- `:oil_facility`
- `:port`
- `:airport`
- `:military_base`

Data is fetched from:

- `https://overpass-api.de/api/interpreter`

## Architecture

- Worker: `lib/world_tracker/workers/locations.ex`
- Fetcher: `lib/world_tracker/locations/overpass_client.ex`
- Context: `lib/world_tracker/locations.ex`
- Schema: `lib/world_tracker/locations/location.ex`
- Oban config: `config/config.exs`

Flow per type:

1. `Workers.Locations.perform/1` calls `OverpassClient.fetch_locations(type)`
2. `Locations.replace_locations_by_type(type, attrs_list)` deletes existing rows for that type
3. Fresh rows are inserted in bulk (`Repo.insert_all/2`)
4. PubSub broadcast is sent on `Locations.topic/0` with `{:locations_updated, type}`

## Scheduling and queue

Configured in `config/config.exs`:

- Queue: `locations: 1`
- Cron: `"0 3 * * *"` (daily at 03:00)
- Fetcher config: `overpass_client: WorldTracker.Locations.OverpassClient`

## Data replacement behavior

This pipeline intentionally uses **full replacement** by type.

- Existing rows for a type are deleted before inserting new ones.
- This keeps the dataset fully programmatic and aligned with current Overpass output.
- Seeded `data_center` and `oil_facility` data is overwritten after the first successful run.

## Running manually

From `iex`:

```elixir
WorldTracker.Workers.Locations.enqueue()
```

Or perform directly in test/dev context:

```elixir
Oban.Testing.perform_job(WorldTracker.Workers.Locations, %{})
```

## Testing

Worker test coverage is in:

- `test/world_tracker/workers/locations_test.exs`

Support files:

- Stub fetcher: `test/support/stubs/overpass_client_stub.ex`
- Fixtures: `test/support/fixtures/locations_fixtures.ex`

The test suite swaps `:overpass_client` to the stub and verifies:

- enqueue behavior on `:locations` queue
- full-replace behavior per type
- `{:locations_updated, type}` broadcasts

## Troubleshooting

- If jobs do not run, verify Oban queue config includes `locations: 1`.
- If no data is stored, check Overpass response status and logs for `failed polling locations`.
- If running `mix precommit` fails with DB connection errors, ensure Postgres is running on the configured host/port.
