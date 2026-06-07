source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "pg", "~> 1.5"           # primary database
gem "sqlite3", ">= 2.1"     # Solid stack (cache/queue/cable) in production
gem "puma", ">= 5.0"
gem "faraday"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "webmock"
  gem "factory_bot_rails"
end

group :development do
  gem "ruby-lsp", require: false
  gem "ruby-lsp-rails", require: false
end
