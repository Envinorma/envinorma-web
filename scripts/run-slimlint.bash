#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Running Slim Lint"
slim-lint app/views/
