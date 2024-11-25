#!/bin/bash
set -e

# Ensure test.local.yml is created from test.local-ci.yml if it doesn't already exist
if [ ! -f config/settings/test.local.yml ]; then
  echo "Creating test.local.yml from test.local-ci.yml..."
  cp config/settings/test-local-ci.yml config/settings/test.local.yml
fi

# Wait for dependent services to be ready
wait-for-it postgres:5432 -- echo "PostgreSQL is up"
wait-for-it memcached:11211 -- echo "Memcached is up"
wait-for-it rabbitmq:5672 -- echo "RabbitMQ is up"
wait-for-it sunspot:8983 -- echo "Sunspot is up"
wait-for-it sqs-mock:9324 -- echo "SQS Mock is up"
wait-for-it minio:9000 -- echo "MinIO is up"

# Set the database environment to test
echo "Setting database environment to test..."
RAILS_ENV=test bundle exec rails db:environment:set RAILS_ENV=test

# Prepare the test database
echo "Preparing the test database..."
RAILS_ENV=test bundle exec rails db:drop db:create db:schema:load

# Execute the provided command
exec "$@"
