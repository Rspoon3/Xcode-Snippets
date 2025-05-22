#!/bin/bash

LOG_FILE="/tmp/snippet-sync-debug.log"
FSWATCH="/opt/homebrew/bin/fswatch"
REPO_DIR="/Users/richardwitherspoon/Library/Developer/Xcode/UserData/CodeSnippets"

echo "Sync watcher started at $(date)" >> "$LOG_FILE"
cd "$REPO_DIR"

$FSWATCH -0 . | while read -d "" event
do
  echo "Detected change at $(date)" >> "$LOG_FILE"

  git add -A
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
    echo "No changes to commit at $(date)" >> "$LOG_FILE"
    osascript -e 'display notification "No changes to sync 💤" with title "Xcode Snippets Auto Sync"'
  fi
done
