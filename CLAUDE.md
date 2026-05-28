# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Start server
bin/rails server

# Database setup
bin/rails db:create db:migrate

# Run all tests
bundle exec rspec

# Run a single spec file
bundle exec rspec spec/services/nhtsa_service_spec.rb

# Run a single example by line number
bundle exec rspec spec/services/nhtsa_service_spec.rb:42

# Lint
bin/rubocop

# Full CI suite (setup, rubocop, bundler-audit, brakeman)
bin/ci
```

## Architecture

This is a Rails 8.1 API-only app. The core is an ETL pipeline for VIN decoding:

```
NhtsaService → NhtsaAssembler → VinLookupService → VehiclePresenter
  (Extract)      (Transform)        (Load)            (Shape)
```

All pipeline classes live in `app/services/`. The pipeline produces value objects (`VehicleData`, `PowertrainData`) — plain Ruby structs defined there — not ActiveRecord models.

**Multi-tenancy** is config-driven: each `Dealer` has a `display_config` JSON column controlling which fields appear in responses and what their labels are. Adding a new dealer with different field behavior requires no code change. The `VehiclePresenter` applies this config as the final step before serialization.

**Authentication** flows through `Api::V1::BaseController` via `X-Dealer-API-Key` header, which sets `@current_dealer` for all API controllers.

## Data Models

- **`Dealer`** — has `api_key` (via `has_secure_token`), `name`, `display_config` (JSON text)
- **`VehicleLookup`** — NHTSA decode cache; unique on `vin`, stores full `raw_data` JSON
- **`DealerInventory`** — dealer-scoped unit data (color, price_cents, mileage, status, packages); belongs to `Dealer`, links to `VehicleLookup` by `vin` string — no foreign key, they compose at the service layer
- **`VehicleData`** / **`PowertrainData`** — value object structs in `app/services/`; `PowertrainData` type is one of `:gas`, `:mild_hybrid`, `:hybrid`, `:plugin_hybrid`, `:ev`, `:fuel_cell`

`price_cents` stores price as an integer (cents) to avoid float precision issues.

## Testing Conventions

- WebMock is configured globally in `spec/support/webmock.rb` — all real network calls are blocked. Stub the NHTSA endpoint in service specs.
- NHTSA response fixtures for gas, EV, and PHEV vehicles live in `spec/fixtures/`. Use these for `NhtsaAssembler` tests. Fixtures use the real NHTSA `Electrification Level` strings (e.g. `"BEV (Battery Electric Vehicle)"`), not the bare token — the assembler matches on prefix, so fixtures must reflect the real wire format.
- Service objects are tested in isolation; request specs (`spec/requests/`) test the full HTTP stack.
- FactoryBot factories are in `spec/factories/`. The default `:vehicle_lookup` factory uses the gas fixture VIN `5N1DL0MM1KC557518`.
- Use RSpec doubles to stub `NhtsaService` in `VinLookupService` tests — don't let the cache miss path hit the real HTTP layer.

## Routes (planned)

```ruby
namespace :api do
  namespace :v1 do
    resources :vehicles, only: [:show], param: :vin  # GET /api/v1/vehicles/:vin
    resources :inventory                              # full CRUD
  end
end
```

`InventoryController#show` supports `?include_decode=true` to merge the VIN decode via `VehiclePresenter`.

## Error Handling Convention

| Scenario | Status |
|---|---|
| Missing/invalid API key | 401 |
| Invalid VIN format | 422 |
| VIN not in NHTSA | 404 |
| NHTSA API error/timeout | 502 |
| Cross-dealer inventory access | 404 (not 403 — avoids leaking existence) |
