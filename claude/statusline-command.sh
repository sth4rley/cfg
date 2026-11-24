#!/bin/sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')

# Git branch (skip optional locks)
branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)

# Context window percentage
context=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# 5-hour rate limit percentage
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# Build status line
parts=""

# Working directory
parts="$cwd"

# Git branch
[ -n "$branch" ] && parts="$parts ($branch)"

# Context
[ -n "$context" ] && parts="$parts | context: $(printf '%.0f' "$context")%"

# 5hr rate limit
[ -n "$five_hr" ] && parts="$parts | 5hr: $(printf '%.0f' "$five_hr")%"

# Model
parts="$parts | $model"

echo "$parts"
