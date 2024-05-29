#!/bin/bash

# Define the cut-off date
CUTOFF_DATE="2024-03-12"

# Navigate to the desired directory within the repository
cd frameworks/base || { echo "Directory frameworks/base does not exist."; exit 1; }

# Get the latest commit date across all branches
LATEST_COMMIT_DATE=$(git for-each-ref --sort=-committerdate --format='%(committerdate:iso8601)' refs/heads/ | head -n 1 | cut -d' ' -f1)
LATEST_COMMIT_HASH=$(git for-each-ref --sort=-committerdate --format='%(objectname)' refs/heads/ | head -n 1)

# Convert dates to seconds since epoch for comparison
LATEST_COMMIT_DATE_SECONDS=$(date -d "$LATEST_COMMIT_DATE" +%s)
CUTOFF_DATE_SECONDS=$(date -d "$CUTOFF_DATE" +%s)

# Function to find the commit before the cut-off date across all branches
find_commit_before_cutoff() {
  # Find the commit before the cut-off date across all branches
  COMMIT_BEFORE_CUTOFF=$(git rev-list -n 1 --before="$CUTOFF_DATE" --all)

  if [ -z "$COMMIT_BEFORE_CUTOFF" ]; then
    echo "No commit found before $CUTOFF_DATE."
    exit 1
  fi

  echo "$COMMIT_BEFORE_CUTOFF"
}

# Compare the latest commit date with the cut-off date
if [ "$LATEST_COMMIT_DATE_SECONDS" -gt "$CUTOFF_DATE_SECONDS" ]; then
  echo "Latest commit date $LATEST_COMMIT_DATE is after the cut-off date $CUTOFF_DATE."
  COMMIT_BEFORE_CUTOFF=$(find_commit_before_cutoff)
  # Revert to the commit before the cut-off date
  git reset --hard "$COMMIT_BEFORE_CUTOFF"
  echo "Reverted to commit $COMMIT_BEFORE_CUTOFF dated $(git log -1 --format=%ci "$COMMIT_BEFORE_CUTOFF")."
else
  echo "No commit is after the cut-off date $CUTOFF_DATE. No action needed."
fi
