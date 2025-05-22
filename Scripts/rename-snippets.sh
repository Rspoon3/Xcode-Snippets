#!/bin/bash

# Go to the folder where your .codesnippet files live
cd ~/Library/Developer/Xcode/UserData/CodeSnippets || exit

for file in *.codesnippet; do
  # Extract the title from the plist using PlistBuddy
  title=$(/usr/libexec/PlistBuddy -c "Print IDECodeSnippetTitle" "$file" 2>/dev/null)

  if [[ -n "$title" ]]; then
    # Make a safe filename: lowercase, no spaces/special chars
    safe_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-|-$//g')
    new_filename="${safe_title}.codesnippet"

    # If the filename is already correct, skip
    if [[ "$file" != "$new_filename" && ! -e "$new_filename" ]]; then
      echo "Renaming '$file' → '$new_filename'"
      mv "$file" "$new_filename"
    fi
  fi
done
