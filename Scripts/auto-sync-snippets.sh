#!/bin/bash

LOG_FILE="/tmp/snippet-sync-debug.log"
FSWATCH="/opt/homebrew/bin/fswatch"
REPO_DIR="/Users/richardwitherspoon/Library/Developer/Xcode/UserData/CodeSnippets"

echo "=== Sync watcher started at $(date) ===" >> "$LOG_FILE"
cd "$REPO_DIR"

# Much more permissive fswatch - catch everything in the directory
$FSWATCH -0 -r . | while read -d "" event
do
  echo "Raw event detected: $event at $(date)" >> "$LOG_FILE"
  
  # Only process if it's a .codesnippet file
  if [[ "$event" == *.codesnippet ]]; then
    echo "Processing .codesnippet file: $event" >> "$LOG_FILE"
    
    # Wait longer to ensure file operations are complete
    sleep 2
    
    # Show what git sees
    echo "=== Git status before processing ===" >> "$LOG_FILE"
    git status --porcelain >> "$LOG_FILE" 2>&1
    echo "=== End git status ===" >> "$LOG_FILE"
    
    # Add all changes
    git add -A >> "$LOG_FILE" 2>&1
    
    # Check if there are staged changes
    if ! git diff --cached --quiet; then
      echo "Found staged changes, committing..." >> "$LOG_FILE"
      
      if git commit -m "Auto-sync updated snippets on $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE" 2>&1; then
        echo "Commit successful, attempting push..." >> "$LOG_FILE"
        
        if git push origin main >> "$LOG_FILE" 2>&1; then
          echo "SUCCESS: Pushed changes at $(date)" >> "$LOG_FILE"
          osascript -e 'display notification "Snippets synced to GitHub ✅" with title "Xcode Snippets Auto Sync"'
        else
          echo "ERROR: Push failed at $(date)" >> "$LOG_FILE"
          osascript -e 'display notification "Git push failed ❌" with title "Xcode Snippets Auto Sync"'
        fi
      else
        echo "ERROR: Commit failed at $(date)" >> "$LOG_FILE"
        osascript -e 'display notification "Git commit failed ❌" with title "Xcode Snippets Auto Sync"'
      fi
    else
      echo "No staged changes found at $(date)" >> "$LOG_FILE"
    fi
  else
    echo "Ignoring non-snippet file: $event" >> "$LOG_FILE"
  fi
done
