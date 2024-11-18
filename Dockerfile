# Use the Ruby 3.1.2 base image
FROM ruby:3.1.2

# Set environment variables
ARG rails_env=development
ENV RAILS_ENV=$rails_env
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

# Install required packages
RUN apt-get update && apt-get install -y \
    nodejs \
    libmemcached-dev \
    libmagic-dev \
    yarn \
    postgresql-client \
    memcached \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock first for dependency caching
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Copy entrypoint script to container and make it executable
COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

# Set entrypoint to ensure settings are loaded before the main command
ENTRYPOINT ["docker-entrypoint.sh"]

# Copy the rest of the application code
COPY . ./

# Expose port 3000 to access the Rails app
EXPOSE 3000

# Command to remove stale server PID and start the Rails server
CMD ["sh", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]
