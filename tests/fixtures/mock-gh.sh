#!/bin/bash
# Mock gh CLI for testing gh-describe action
# Returns predictable data without requiring network access or real token

ARGS="$*"

if echo "$ARGS" | grep -q "graphql"; then
  # Return total commit count for GraphQL query
  echo '{"data":{"repository":{"object":{"history":{"totalCount":1}}}}}'
elif echo "$ARGS" | grep -q "tags"; then
  # Return tags list in jq output format: ["sha","name"] per line
  echo '["abc1234567890123456789012345678901234567890","v2.1.0"]'
elif echo "$ARGS" | grep -q "commits"; then
  # Return commit SHA(s), one per line
  echo "abc1234567890123456789012345678901234567890"
else
  echo "mock gh: unhandled args: $ARGS" >&2
  exit 1
fi
