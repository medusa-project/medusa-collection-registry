#!/bin/bash
set -e

# Load Config settings explicitly to ensure they're available at startup.
# In Docker, there can be timing or load order issues with the Config gem settings, 
# which may cause `Settings` to be `nil` or partially loaded when the application starts 
ruby -e "require 'config'; Config.load_and_set_settings(YAML.safe_load(File.read('config/settings.yml'), permitted_classes: [Symbol]))"

# Run the command passed to this script 
exec "$@"