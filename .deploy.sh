#! /usr/bin/env bash

set -e

# Install deps
bundle install --path .bundle

# Build site
rm -rf "${TARGET_DIR:-_site}"/*
bundle exec jekyll build -d "${TARGET_DIR:-_site}"
