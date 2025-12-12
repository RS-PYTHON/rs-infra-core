#!/bin/bash
# Copyright 2025 Airbus, CS Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# cleanup_levels.sh
# Progressive cleanup script controlled by a "level" parameter (0..14).
# Level 0 = no changes. Level 14 = run all cleanup stages.
#
# WARNING: These commands remove files and packages. Review and adapt before running.
# Run as root or with sudo.

set -euo pipefail

# Default level (if not provided) -> full cleanup
REQUESTED="${1:-14}"

# Normalize "all" or similar inputs
if [[ "$REQUESTED" == "all" ]]; then
  LEVEL=14
else
  # ensure integer
  if ! [[ "$REQUESTED" =~ ^[0-9]+$ ]]; then
    echo "Invalid level: $REQUESTED. Provide an integer between 0 and 14, or 'all'." >&2
    exit 2
  fi
  LEVEL="$REQUESTED"
fi

# clamp between 0 and 14
if [ "$LEVEL" -lt 0 ]; then LEVEL=0; fi
if [ "$LEVEL" -gt 14 ]; then LEVEL=14; fi

LOG="cleanup_runner_files.log"
echo "=== Cleanup run at $(date) (requested level: $REQUESTED, executing level: $LEVEL) ===" | tee -a "$LOG"

# helper: print header + df
log_df() {
  local tag="$1"
  echo "---- $(date) : $tag ----" | tee -a "$LOG"
  df -h | tee -a "$LOG"
}

# helper: get available KB for root filesystem
avail_kb() {
  # Using POSIX-friendly parsing: df --output=avail -k /
  df --output=avail -k / 2>/dev/null | tail -1 | tr -d '[:space:]'
}

# helper: run a command with pre/post df and show freed GB
run_action() {
  local name="$1"; shift
  local cmd="$*"

  echo "" | tee -a "$LOG"
  echo ">>> ACTION: $name" | tee -a "$LOG"
  local before_kb
  before_kb=$(avail_kb) || before_kb=0
  log_df "Before: $name"

  echo "+ Running: $cmd" | tee -a "$LOG"
  # run the command (do not fail the whole script on non-zero if command uses || true)
  eval "$cmd"

  local after_kb
  after_kb=$(avail_kb) || after_kb=0
  log_df "After: $name"

  # compute freed KB and present in human-friendly GB
  local freed_kb=$(( after_kb - before_kb ))
  if [ "$freed_kb" -lt 0 ]; then
    # negative means less available (maybe other processes used space). show absolute change.
    printf "Change in available space: %d KB (%.3f GB)\n" "$freed_kb" "$(awk -v k="$freed_kb" 'BEGIN{printf "%.3f", k/1024/1024}')"
  else
    printf "Freed: %d KB (%.3f GB)\n" "$freed_kb" "$(awk -v k="$freed_kb" 'BEGIN{printf "%.3f", k/1024/1024}')"
  fi | tee -a "$LOG"
  echo "" | tee -a "$LOG"
}

# Ordered actions (1 .. 14). These correspond to the cleanup stages.
# Adjust the commands to your environment. Commands are intentionally explicit.
# For destructive commands (rm -rf) verify paths before using in production.

actions=(
  # 1
  "Remove Chromium (/usr/local/share/chromium)|sudo rm -rf /usr/local/share/chromium || true"
  # 2
  "Remove Microsoft/Google builds (/opt/microsoft /opt/google)|sudo rm -rf /opt/microsoft /opt/google || true"
  # 3
  "Remove Swift toolchain (/usr/share/swift)|sudo rm -rf /usr/share/swift || true"
  # 4
  "Remove Java JDKs (/usr/lib/jvm)|sudo rm -rf /usr/lib/jvm || true"
  # 5
  "Remove PowerShell (/usr/local/share/powershell)|sudo rm -rf /usr/local/share/powershell || true"
  # 6
  "Remove Haskell (ghcup) (/usr/local/.ghcup)|sudo rm -rf /usr/local/.ghcup || true"
  # 7
  "Remove .NET SDKs (/usr/share/dotnet)|sudo rm -rf /usr/share/dotnet || true"
  # 8
  "Remove Android SDKs (/usr/local/lib/android)|sudo rm -rf /usr/local/lib/android || true"
  # 9
  "Remove Julia installations (/usr/local/julia*)|sudo rm -rf /usr/local/julia* || true"
  #10
  "Remove CodeQL and hosted toolcache (/opt/hostedtoolcache)|sudo rm -rf /opt/hostedtoolcache || true"
  #11
  "Docker system prune (docker system prune -af)|docker system prune -af || true"
  #12
  "Docker builder prune (docker builder prune -af)|docker builder prune -af || true"
  #13
  "Remove Azure CLI (/opt/az)|sudo rm -rf /opt/az || true"
  #14
  "Final autoremove and cache cleanup (apt-get and caches)|sudo apt-get autoremove -y || true; sudo apt-get clean -y || true; sudo rm -rf /root/.cache /home/*/.cache || true"
)

TOTAL_ACTIONS=${#actions[@]}  # should be 14
echo "Prepared $TOTAL_ACTIONS actions. Will execute first $LEVEL action(s)." | tee -a "$LOG"

# Show initial df
log_df "Initial (level 0)"

# Execute actions 1..LEVEL
count=0
for idx in "${!actions[@]}"; do
  action_index=$((idx+1))
  if [ "$action_index" -gt "$LEVEL" ]; then
    break
  fi
  IFS='|' read -r title cmd <<< "${actions[$idx]}"
  run_action "Level $action_index - $title" "$cmd"
  count=$((count+1))
done

log_df "Completed actions (executed $count action(s))"
echo "=== Cleanup finished at $(date) — executed $count action(s) ===" | tee -a "$LOG"

# Optional: print quick summary of final available space
final_kb=$(avail_kb)
printf "Final available space on / : %d KB (%.3f GB)\n" "$final_kb" "$(awk -v k="$final_kb" 'BEGIN{printf "%.3f", k/1024/1024}')" | tee -a "$LOG"
