#!/bin/bash

# Set project root (current directory)
PROJ_DIR="$(pwd)"
ARCHIVE="${PROJ_DIR}/_archive_$(date +%Y%m%d_%H%M%S)"
LOG="${PROJ_DIR}/CLEANUP_LOG.md"

echo "## Clean-up started: $(date)" >> "$LOG"

# 1. Create an archive folder for all questionable files
mkdir -p "$ARCHIVE"

# 2. Aggressively remove build, temp, and common clutter (safe to delete)
rm -rf dist .next .turbo .replit .DS_Store coverage out .cache .idea .vscode .vercel .env* *.log

# 3. Remove node_modules and lock files (will be re-installed)
rm -rf node_modules package-lock.json yarn.lock pnpm-lock.yaml

# 4. Move stray or questionable files to archive
for f in *~ *.bak *.tmp *.old *.backup
do
  [ -e "$f" ] && mv "$f" "$ARCHIVE/"
done

# 5. Move any random files/folders you want to review later (edit as needed)
for f in test tests __tests__ playground scratch temp backup
do
  [ -e "$f" ] && mv "$f" "$ARCHIVE/"
done

# 6. Inventory what remains and save it
echo -e "\n### Inventory after clean-up:\n" >> "$LOG"
ls -la >> "$LOG"

# 7. Install dependencies fresh
echo -e "\n### Installing dependencies..." >> "$LOG"
npm install >> "$LOG" 2>&1

# 8. Start dev server and log status
echo -e "\n### Starting dev server..." >> "$LOG"
npm run dev >> "$LOG" 2>&1 &

echo -e "\n## Clean-up completed: $(date)\n" >> "$LOG"
echo "All questionable files/folders were moved to: $ARCHIVE" >> "$LOG"
echo "Check CLEANUP_LOG.md for details. Review _archive before deleting permanently."

echo "----------------------"
echo "Aggressive clean complete."
echo "Dev server should now be running."
echo "Review $ARCHIVE and $LOG for details."
echo "----------------------"
