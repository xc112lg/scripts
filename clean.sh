xml_dir=".repo/manifests"
paths=$(xmlstarlet sel -t -v "//project/@path" "$xml_dir"/*.xml | sed 's/$/\//')



# Remove each file
for path in $paths; do
    cd "$path"
    # Count the number of slashes in the path
    num_slashes=$(tr -dc '/' <<< "$path" | awk '{ print length; }')
# Define the target date
target_date="2024-03-12"


  # Get the list of commits with their dates
  commits=$(git log --pretty=format:"%H %cd" --date=iso 2>>"$LOG_FILE")
  if [ $? -ne 0 ]; then
    echo "Failed to retrieve git log." | tee -a "$LOG_FILE"
    exit 1
  fi

  # Iterate over the commits
  echo "Processing commits..." | tee -a "$LOG_FILE"
  echo "$commits" | while IFS= read -r line; do
  commit_hash=$(echo "$line" | awk '{print $1}')
  commit_date=$(echo "$line" | cut -d' ' -f2-)
  echo "Checking commit: $commit_hash, date: $commit_date" | tee -a "$LOG_FILE"

  # Convert commit date to epoch time
  commit_epoch=$(date_to_epoch "$commit_date")

  if [ $commit_epoch -gt $target_epoch ]; then
    echo "Found commit after $TARGET_DATE: $commit_hash" | tee -a "$LOG_FILE"

    # Find the latest commit before the target date
    previous_commit=$(git log --before="$TARGET_DATE" --pretty=format:"%H" -n 1 2>>"$LOG_FILE")
    if [ $? -ne 0 ]; then
      echo "Failed to retrieve previous commit." | tee -a "$LOG_FILE"
      exit 1
    fi

    if [ -n "$previous_commit" ]; then
      echo "Reverting commit before $TARGET_DATE: $previous_commit" | tee -a "$LOG_FILE"
      git revert --no-commit "$previous_commit" 2>>"$LOG_FILE"
      if [ $? -ne 0 ]; then
        echo "Failed to revert commit: $previous_commit" | tee -a "$LOG_FILE"
        exit 1
      fi

      # Remove files added by the reverted commit
      git diff --name-only "$previous_commit" | xargs rm -rf

      git commit -am "Revert commit $previous_commit" 2>>"$LOG_FILE"
      if [ $? -ne 0 ]; then
        echo "Failed to commit revert" | tee -a "$LOG_FILE"
        exit 1
      fi

      # Check if the commit has been reverted
      revert_check=$(git log --grep="Revert" --grep="$previous_commit" 2>>"$LOG_FILE")
      if [ -n "$revert_check" ]; then
        echo "Commit $previous_commit has been successfully reverted." | tee -a "$LOG_FILE"
      else
        echo "Revert of commit $previous_commit failed." | tee -a "$LOG_FILE"
      fi
    else
      echo "No commit found before $TARGET_DATE" | tee -a "$LOG_FILE"
    fi

    # Break after processing the first commit after target date
    break
  else
    echo "Commit $commit_hash is before $TARGET_DATE, skipping." | tee -a "$LOG_FILE"
  fi

  done






    for ((i=0; i<num_slashes; i++)); do
        cd ..
    done

done