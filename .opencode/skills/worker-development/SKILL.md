---
name: worker-development
description: Create and manage background workers using Oban with queues and scheduled jobs
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: phoenix
---

## What I do

- Create worker modules that follow Oban best practices
- Define queues in config/config.exs for proper job processing
- Set up scheduled/periodic jobs using Oban's Cron plugin
- Place workers in the standard lib/world_tracker/workers directory
- Ensure proper testing patterns for worker functionality

## Standard Worker Location

All workers should be placed in:
```
lib/world_tracker/workers/
```

Example worker module path:
```
lib/world_tracker/workers/market_price_poller.ex
```

## Worker Implementation Guidelines

### Basic Worker Structure

```elixir
defmodule WorldTracker.Workers.MyWorker do
  use Oban.Worker, queue: :my_queue

  @impl true
  def perform(%Oban.Job{args: args}) do
    # Worker logic here
    {:ok, result}
  end

  # Required for unit testing and manual triggering from iex
  def enqueue(args \\ %{}) do
    Oban.insert(%WorldTracker.Workers.MyWorker{args: args})
  end
end
```

### Queue Configuration

Queues must be defined in `config/config.exs`:

```elixir
config :world_tracker, Oban,
  queues: [
    default: 10,
    my_queue: 5,
    # other queues...
  ],
  plugins: [
    # Oban.Plugins.Cron config for scheduled jobs
  ]
```

### Scheduled Jobs with Cron

For recurring jobs, use the Oban.Cron plugin:

```elixir
# In config/config.exs
config :world_tracker, Oban,
  plugins: [
    {Oban.Plugins.Cron, crontab: [
      {"* * * * *", {WorldTracker.Workers.MyWorker, :perform, [%{arg: "value"}]}, queue: :my_queue},
      # "0 */5 * * *" for every 5 minutes
      # "0 0 * * *" for daily at midnight
    ]}
  ]
```

### Worker Testing Pattern

In `config/test.exs`, configure Oban for testing:

```elixir
config :world_tracker, Oban,
  plugins: [Oban.Plugins.Pruner],
  queues: [],
  # Enable testing mode
  # (Oban.Testing is typically configured in test_helper.exs)
```

Test workers using `Oban.Testing`:

```elixir
defmodule WorldTracker.Workers.MyWorkerTest do
  use ExUnit.Case, async: true
  import Oban.Testing

  test "performs work correctly" do
    job = %{arg: "value"}
    {:ok, _pid} = MyWorker.perform(job)
    # or using Oban.Testing.perform_job/2
    assert perform_job(MyWorker, job) == {:ok, expected_result}
  end
end
```

## Common Tasks

### Create a New Worker

1. Create module in `lib/world_tracker/workers/your_worker.ex`
2. Implement `use Oban.Worker` with appropriate queue
3. Add queue definition to `config/config.exs`
4. For scheduled work, add cron entry to Oban config
5. Create corresponding test in `test/world_tracker/workers/your_worker_test.exs`

### Manual Job Enqueuing

```elixir
# From anywhere in your code
WorldTracker.Workers.YourWorker.enqueue(%{key: "value"})
# or with specific queue
WorldTracker.Workers.YourWorker.enqueue(%{key: "value"}, queue: :custom_queue)
```

### Monitoring Workers

- Use Oban Web UI if enabled
- Check Oban telemetry events
- Review logs for worker execution

## Files to Update Together

When creating/modifying workers, typically update:
- `lib/world_tracker/workers/your_worker.ex` (the worker module)
- `config/config.exs` (queue and cron configuration)
- `test/world_tracker/workers/your_worker_test.exs` (worker tests)
- `config/test.exs` (if adjusting test Oban configuration)
- `lib/world_tracker/application.ex` (if adding new supervisors, though usually not needed for Oban)

## When to Use This Skill

Use this skill when you need to:
- Create background processing jobs
- Implement scheduled/periodic tasks
- Offload work from request/response cycles
- Ensure reliable job execution with retries
- Monitor and manage background work through Oban's UI