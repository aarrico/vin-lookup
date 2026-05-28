# VIN Lookup Platform

A multi-tenant Rails JSON API for decoding vehicle identification numbers (VINs). Built as a learning project to explore Ruby on Rails conventions, TDD with RSpec, and the config-driven architecture patterns common in automotive SaaS platforms.

## What it does

- Decodes VINs via the [NHTSA public API](https://vpic.nhtsa.dot.gov/api/) and caches results in SQLite
- Models all powertrain types: gas, mild hybrid, hybrid, plug-in hybrid, and EV
- Supports multiple dealers, each authenticated by API key
- Each dealer has a JSON display config that controls which fields appear in their responses — the same VIN decode can look different depending on who's asking
- Dealers can attach inventory records to VINs (color, price, mileage, status, packages)

## Short-term goals

- [ ] Complete the ETL service pipeline: `NhtsaService` → `VehicleAssembler` → `VinLookupService` → `VehiclePresenter`
- [ ] Full RSpec coverage with WebMock (no real network calls in tests)
- [ ] REST endpoints: `GET /api/v1/vehicles/:vin` and full CRUD on `/api/v1/inventory`
- [ ] Demonstrate config-driven multi-tenancy at the API layer

## Running locally

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

## Running tests

```bash
bundle exec rspec
```

## Stack

- Ruby on Rails 8.1 (API-only)
- SQLite via ActiveRecord
- Faraday for HTTP
- RSpec + WebMock + FactoryBot
