#!/bin/bash

# --- Configuration ---
PROJECT_DIR="/Users/abdiasernestogarcia/Desktop/❤️ ART & CO PROJECTS/CAROLINA THE DOODLER/projects/DoodleMashup-Replit"
LOG_FILE="$PROJECT_DIR/TEST_LOG.md"
DEV_URL="http://localhost:5173"

# --- Helper Functions ---
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_to_file() {
    echo -e "$1" >> "$LOG_FILE"
}

# --- Main Script ---
cd "$PROJECT_DIR" || { echo "Error: Project directory not found at $PROJECT_DIR"; exit 1; }

# Initialize or update the log file
if [ ! -f "$LOG_FILE" ]; then
    log_to_file "# 🧪 Doodle Mashup - Test & Validation Log"
fi
log_to_file "\n---\n### ✅ **New Test Run Started: $(date)**\n"

# 1. Install Dependencies
log "Installing dependencies..."
npm install > npm_install.log 2>&1
if [ $? -eq 0 ]; then
    log "Dependencies installed successfully."
    log_to_file "- **Dependency Check:** ✅ PASSED"
else
    log "Error: npm install failed."
    log_to_file "- **Dependency Check:** ❌ FAILED"
    log_to_file "\n**Error Details:**\n\`\`\`\n$(cat npm_install.log)\n\`\`\`"
    exit 1
fi

# 2. Start Dev Server & Check for Build Errors
log "Starting dev server..."
(npm run dev &> npm_dev.log &)
DEV_PID=$!

# Give the server a moment to start up or fail
sleep 10

if kill -0 "$DEV_PID" 2>/dev/null; then
    # Server is running, check for build errors in the log
    if grep -q "ready in" npm_dev.log; then
        # Dynamically get the URL from the log
        DEV_URL=$(grep -o 'http://localhost:[0-9]\+' npm_dev.log | head -n 1)
        
        log "Dev server started successfully."
        log_to_file "- **Build Status:** ✅ PASSED"
        log_to_file "- **URL:** [$DEV_URL]($DEV_URL)"
        
        # 3. Open URL in Browser
        log "Opening $DEV_URL in the default browser..."
        open "$DEV_URL"
        
        log_to_file "\n**Next Steps:** Manually check the browser for UI and console errors."
    else
        log "Error: Dev server started but might have issues."
        log_to_file "- **Build Status:** ⚠️ WARNING - Server running, but success message not found."
        log_to_file "\n**Log Details:**\n\`\`\`\n$(cat npm_dev.log)\n\`\`\`"
    fi
    # Clean up the running server process
    kill "$DEV_PID"
else
    log "Error: Dev server failed to start."
    log_to_file "- **Build Status:** ❌ FAILED"
    log_to_file "\n**Error Details:**\n\`\`\`\n$(cat npm_dev.log)\n\`\`\`"
    exit 1
fi

log "Validation script finished."
rm npm_install.log npm_dev.log
exit 0
