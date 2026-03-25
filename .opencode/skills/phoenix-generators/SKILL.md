---
name: phoenix-generators
description: Create database schemas and resources using Phoenix generators
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: phoenix
---

## What I do

- Generate database schemas with migrations using `mix phx.gen` commands
- Create contexts, controllers, views, and templates for resources
- Build LiveView interfaces for interactive web applications
- Generate boilerplate code for CRUD operations without manual setup
- Ask clarifying questions about generator type when needed

## Default behavior

**Always use `mix phx.gen` commands** - never manually create migrations or use `mix ecto.migrations` for new schemas. The Phoenix generators create all necessary boilerplate including:

- Ecto schema files
- Database migrations
- Context modules with CRUD functions
- Controllers/views/templates (depending on generator type)
- Tests and fixtures

## Generator types

When the user requests a new resource, ask which type they need:

### `mix phx.gen.live`
- **Use for:** LiveView interfaces with real-time interactivity
- **Generates:** LiveView modules, templates, context, schema, migration
- **Best for:** Modern, interactive applications with real-time updates
- **Example:** `mix phx.gen.live Accounts User users name:string age:integer`

### `mix phx.gen.html`
- **Use for:** Traditional server-rendered HTML interfaces
- **Generates:** Controller, HTML templates, context, schema, migration
- **Best for:** Standard web forms and CRUD pages
- **Example:** `mix phx.gen.html Accounts User users name:string age:integer`

### `mix phx.gen.context`
- **Use for:** API-only or background data structures
- **Generates:** Context module, schema, migration (no web interface)
- **Best for:** Backend logic, APIs, or when UI is handled separately
- **Example:** `mix phx.gen.context Accounts User users name:string age:integer`

### `mix phx.gen.json`
- **Use for:** JSON API endpoints
- **Generates:** Controller, JSON views, context, schema, migration
- **Best for:** REST APIs or mobile backends
- **Example:** `mix phx.gen.json Accounts User users name:string age:integer`

## When to use me

Use this skill when:
- Creating new database resources (users, products, orders, etc.)
- Adding new tables and relationships to existing applications
- Building CRUD interfaces (HTML, JSON, or LiveView)
- Need to generate boilerplate code quickly
- Setting up new contexts or domain boundaries

## How to work on it

### Before generating

1. **Ask for generator type** - Always clarify which type the user needs
2. **Check existing contexts** - Avoid naming conflicts with existing modules
3. **Plan attributes** - Discuss attribute names and types before generation

### Command syntax

```bash
# Basic syntax
mix phx.gen.live Context Schema table_name attr:type [attr:type...]

# With explicit context
mix phx.gen.html Accounts User users name:string age:integer

# Common attribute types
# :string, :text, :integer, :float, :decimal, :boolean, :date, :time, :naive_datetime, :utc_datetime, :binary, :map, :array
```

### After generation

1. **Run migrations:** `mix ecto.migrate`
2. **Add routes:** Follow the output instructions to add routes to router.ex
3. **Run tests:** `mix test` to verify generated code works
4. **Customize as needed:** Generated code is starting point, customize to fit your needs

## Exception: Individual data migrations

**Only for individual data migrations** (not schema creation), you can use:
- `mix ecto.migration` for custom data migrations
- `mix ecto.migrate` to run migrations

But for creating new schemas/resources, always use `mix phx.gen` commands.

## Common tasks

### Create a LiveView resource
```bash
mix phx.gen.live Accounts User users name:string email:string:unique
mix ecto.migrate
# Add routes to router.ex as instructed
```

### Create an HTML resource
```bash
mix phx.gen.html Inventory Product products name:string price:decimal
mix ecto.migrate
# Add routes to router.ex as instructed
```

### Create an API-only resource
```bash
mix phx.gen.context Analytics Metric metrics name:string value:float timestamp:utc_datetime
mix ecto.migrate
```

### Add relationship fields
```bash
mix phx.gen.live Blog Post posts title:string body:text user_id:references:users
mix ecto.migrate
```

## Files to update together

When using generators, typically these files are affected:

- **Schema files:** `lib/my_app/context/schema.ex`
- **Migration files:** `priv/repo/migrations/xxx_create_table.exs`
- **Context files:** `lib/my_app/context.ex`
- **Web files:** `lib/my_app_web/live/schema_live.ex` or `lib/my_app_web/controllers/schema_controller.ex`
- **Router:** `lib/my_app_web/router.ex` (add routes)
- **Tests:** `test/my_app/context_test.exs`, `test/my_app_web/live/schema_live_test.ex`

## Configuration options

Phoenix generators respect these configuration options in `config.exs`:

```elixir
config :my_app, :generators,
  migration: true,           # Generate migrations (default: true)
  binary_id: false,          # Use binary IDs for primary keys
  timestamp_type: :naive_datetime,
  sample_binary_id: "11111111-1111-1111-1111-111111111111"
```

## Common flags

- `--no-migration` - Skip migration generation
- `--binary-id` - Use binary UUIDs for primary keys
- `--no-context` - Don't generate context module
- `--no-schema` - Don't generate schema module
- `--table` - Specify custom table name
- `--web` - Add namespace to web modules
- `--context-app` - For umbrella applications

## Testing pattern

Generated tests include:
- Context tests (CRUD operations)
- Controller/LiveView tests (web interface)
- Fixtures for test data

Run generated tests:
```bash
mix test test/my_app/context_test.exs
mix test test/my_app_web/live/schema_live_test.exs
```

## Debugging

If generation fails:
1. Check for naming conflicts
2. Verify database connection
3. Ensure Phoenix app is properly set up
4. Check attribute syntax (attr:type format)

Common errors:
- Invalid attribute type
- Missing context module
- Duplicate table/column names
- Database connection issues