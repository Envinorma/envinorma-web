#!/usr/bin/env bash

echo "Running pre-push hook"
./scripts/run-rubocop.bash
./scripts/run-slimlint.bash
./scripts/run-tests.bash
./scripts/run-js-tests.bash

# $? stores exit value of the last command
if [ $? -ne 0 ]; then
 echo "Rubocop, SlimLint and Tests must pass before pushing!"
 exit 1
fi
