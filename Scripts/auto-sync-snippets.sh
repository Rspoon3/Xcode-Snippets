#!/bin/bash

LOG_FILE="/tmp/snippet-sync-debug.log"
FSWATCH="/opt/homebrew/bin/fswatch"
REPO_DIR="/Users/richardwitherspoon/Library/Developer/Xcode/UserData/CodeSnippets"

echo "Sync watcher started at $(date)" >> "$LOG_FILE"
cd "$REPO_DIR"

# Simplified fswatch - watch for any changes to .codesnippet files
$FSWATCH -0 --include "\.codesnippet$" --exclude ".*" . | while read -d "" event
do
  echo "Detected change: $event at $(date)" >> "$LOG_FILE"

  # Wait briefly to ensure new files are written completely
  sleep 1

  # Check git status before adding
  echo "Git status before add:" >> "$LOG_FILE"
  git status --porcelain >> "$LOG_FILE" 2>&1

  git add -A
  
  # Check if there are actually changes to commit
  if git diff --cached --quiet; then
    echo "No staged changes to commit at $(date)" >> "$LOG_FILE"
    osascript -e 'display notification "No changes to sync 💤" with title "Xcode Snippets Auto Sync"'
  else
    echo "Committing changes at $(date)" >> "$LOG_FILE"
    git commit -m "Auto-sync updated snippets on $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
      if git push origin main >> "$LOG_FILE" 2>&1; then
        echo "Pushed changes at $(date)" >> "$LOG_FILE"
        osascript -e 'display notification "Snippets synced to GitHub ✅" with title "Xcode Snippets Auto Sync"'
      else
        echo "Push failed at $(date)" >> "$LOG_FILE"
        osascript -e 'display notification "Git push failed ❌" with title "Xcode Snippets Auto Sync"'
      fi
    else
      echo "Commit failed at $(date)" >> "$LOG_FILE"
      osascript -e 'display notification "Git commit failed ❌" with title "Xcode Snippets Auto Sync"'
    fi
  fi
done
