#!/bin/bash

# Define the path to the target directory
TARGET_DIR="frameworks/base"

# Define the cutoff date
CUTOFF_DATE="2024-03-12T00:00:00Z"

# Navigate to the target directory
cd "$TARGET_DIR" || { echo "Directory $TARGET_DIR not found."; exit 1; }

# Find the latest commit before the cutoff date
PRE_MARCH12_COMMIT=$(git rev-list -n 1 --before="$CUTOFF_DATE" HEAD)

if [ -z "$PRE_MARCH12_COMMIT" ]; then
  echo "No commits found before March 12, 2024. No action taken."
else
  # Revert the repository to the state of the commit before March 12, 2024
  git reset --hard "$PRE_MARCH12_COMMIT"
  echo "Repository reverted to commit before March 12, 2024: $PRE_MARCH12_COMMIT"
fi

# Navigate back to the original directory
cd - > /dev/null
