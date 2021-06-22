#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Running Slim Lint"
bundle exec slim-lint app/views/
