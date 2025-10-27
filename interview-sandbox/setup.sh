#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "[sandbox] Building container..."
docker compose build

echo "[sandbox] Starting services..."
docker compose up -d

cd ..
mkdir -p reports

echo "[sandbox] Running bundler-audit (if Gemfile present)..."
if [ -f Gemfile ]; then
  docker compose exec -T app bash -lc "bundle config set path 'vendor/bundle' && bundle install"
  docker compose exec -T app bash -lc "bundle exec bundler-audit update && bundle exec bundler-audit check" || true
fi

echo "[sandbox] Running brakeman (Rails only)..."
if [ -f Gemfile ]; then
  docker compose exec -T app bash -lc "gem install brakeman && brakeman -q -o reports/brakeman.txt" || true
fi

echo "[sandbox] Running rubocop (if configured)..."
if [ -f .rubocop.yml ]; then
  docker compose exec -T app bash -lc "gem install rubocop rubocop-rails rubocop-rspec && rubocop" || true
fi

echo "[sandbox] Running gitleaks..."
gitleaks detect --no-banner --report-path reports/gitleaks.json || true

echo "[sandbox] Done. Visit http://localhost:3000 when app is running."
