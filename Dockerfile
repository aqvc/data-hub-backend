# syntax=docker/dockerfile:1

# ---- Build stage ----
FROM ruby:3.3.6-slim AS builder

ENV BUNDLE_WITHOUT="development:test" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  RAILS_ENV=production

RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential \
  git \
  libpq-dev \
  libyaml-dev \
  pkg-config && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 && \
  rm -rf "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

RUN bundle exec bootsnap precompile --gemfile app/ lib/ || true

# ---- Runtime stage ----
FROM ruby:3.3.6-slim AS runtime

ENV BUNDLE_WITHOUT="development:test" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  RAILS_ENV=production \
  RAILS_LOG_TO_STDOUT="1" \
  RAILS_SERVE_STATIC_FILES="1" \
  PORT=3000

RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  libpq5 \
  libyaml-0-2 \
  tzdata \
  curl && \
  rm -rf /var/lib/apt/lists/*

RUN groupadd --system --gid 1000 rails && \
  useradd  --system --uid 1000 --gid 1000 --create-home rails

WORKDIR /app

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=rails:rails /app /app

RUN mkdir -p tmp/pids log && chown -R rails:rails tmp log
USER rails

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
