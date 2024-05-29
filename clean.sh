#!/bin/bash

# Define the cut-off date
CUTOFF_DATE="2024-03-12"

# Define the branch name
BRANCH_NAME="lineage-21.0"

# Navigate to the desired directory within the repository
cd frameworks/base || { echo "Directory frameworks/base does not exist."; exit 1; }

# Check if the branch exists
if ! git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
  echo "Branch $BRANCH_NAME does not exist."
  exit 1
fi

# Get the date of the latest commit
LATEST_COMMIT_DATE=$(git log -1 --format=%ci | cut -d' ' -f1)

# Convert dates to seconds since epoch for comparison
LATEST_COMMIT_DATE_SECONDS=$(date -d "$LATEST_COMMIT_DATE" +%s)
CUTOFF_DATE_SECONDS=$(date -d "$CUTOFF_DATE" +%s)

# Function to revert to the commit before the cut-off date
revert_to_commit_before_cutoff() {
  # Find the commit before the cut-off date in the specified branch
  COMMIT_BEFORE_CUTOFF=$(git rev-list -n 1 --before="$CUTOFF_DATE" "$BRANCH_NAME")

  if [ -z "$COMMIT_BEFORE_CUTOFF" ]; then
    echo "No commit found before $CUTOFF_DATE."
    exit 1
  fi

  # Revert to that commit
  git reset --hard "$COMMIT_BEFORE_CUTOFF"
  echo "Reverted to commit $COMMIT_BEFORE_CUTOFF dated $(git log -1 --format=%ci "$COMMIT_BEFORE_CUTOFF")."
}

# Compare the latest commit date with the cut-off date
if [ "$LATEST_COMMIT_DATE_SECONDS" -gt "$CUTOFF_DATE_SECONDS" ]; then
  echo "Latest commit date $LATEST_COMMIT_DATE is after the cut-off date $CUTOFF_DATE."
  revert_to_commit_before_cutoff
else
  echo "No commit is after the cut-off date $CUTOFF_DATE. No action needed."
fi
