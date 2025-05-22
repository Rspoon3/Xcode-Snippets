# ✂️ Xcode Snippets Auto Sync

This repository contains my personal Xcode `.codesnippet` files, stored directly in Xcode's native `CodeSnippets` folder and automatically synced to GitHub.

---

## 📁 Folder Structure

This Git repository is initialized directly inside:

```
~/Library/Developer/Xcode/UserData/CodeSnippets
```

All `.codesnippet` files created or modified by Xcode are versioned automatically.

---

## 🔄 Auto-Sync Implementation

A background sync system is set up using:

- [`fswatch`](https://emcrisostomo.github.io/fswatch/): monitors the `CodeSnippets` folder for real-time changes
- `git`: stages, commits, and pushes any snippet changes to GitHub
- `launchd`: keeps the sync script running on macOS login
- `logger` and file logging: tracks activity in the system Console and a local debug file

---

## 🧪 How It Works

1. A `launchd` agent starts on login.
2. It runs a script located at:

   ```
   ~/Library/Developer/Xcode/UserData/CodeSnippets/Scripts/auto-sync-snippets.sh
   ```

3. This script:
   - Monitors the folder for changes
   - Waits briefly to ensure new files are fully saved
   - Runs `git add -A && git commit && git push`
   - Logs to both `/tmp/snippet-sync-debug.log` and macOS Console using `logger`

---

## 🖥 Viewing Logs

### 🔧 Console

Open **Console.app** and search for:

```
snippetsync
```

This shows all commit/push actions performed in the background.

### 📄 Log File

Tail the debug file in Terminal:

```bash
tail -f /tmp/snippet-sync-debug.log
```

---

## ✅ Setup Summary

To use this yourself:

1. Clone the repo directly into:

   ```
   ~/Library/Developer/Xcode/UserData/CodeSnippets
   ```

2. Install `fswatch` via Homebrew:

   ```bash
   brew install fswatch
   ```

3. Copy the `auto-sync-snippets.sh` script and make it executable.
4. Install the LaunchAgent `.plist` into `~/Library/LaunchAgents/`.
5. Load the agent:

   ```bash
   launchctl load ~/Library/LaunchAgents/com.rspoon.snippetsync.plist
   ```

---

## 🚫 Known Limitations

- No GUI notifications (intentionally removed for simplicity)
- Some changes (like whitespace-only edits) may be ignored by `git` unless meaningful
- If you rename a file and Xcode doesn't update the content, Git may not trigger a new commit

---

## 📜 License

MIT License. Use, fork, or adapt as needed for your own workflow.
