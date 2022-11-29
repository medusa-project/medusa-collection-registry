FROM ubuntu:22.04
FROM ruby:3.1.2

ENV RAILS_ENV=development
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

RUN apt-get update && apt-get install -y \
    systemd \
    nodejs \
    libmemcached-dev \
    libmagic-dev \
    yarn \
    postgresql-client \
    memcached

EXPOSE 3000
WORKDIR ./
# Copy the Gemfile as well as the Gemfile.lock and install gems.
# This is a separate step so the dependencies will be cached.
COPY Gemfile Gemfile.lock  ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Copy the main application, except whatever is listed in .dockerignore.
COPY . ./