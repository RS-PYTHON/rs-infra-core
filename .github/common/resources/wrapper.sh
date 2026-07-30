#!/usr/bin/env bash
# Copyright 2023-2026 Airbus, CS Group
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

set -euo pipefail

DRY_RUN=false

declare -a SCRIPTS=()
declare -A SCRIPT_ARGS=()

usage() {
cat <<EOF
Usage:
    $(basename "$0") [OPTIONS] [OPERATIONS]

OPTIONS
    --dry-run      Print commands without executing them
    -h, --help     Show this help

OPERATIONS
    + <script> [arg1 arg2 ...]

        Add or override a script.

    - <script>

        Remove a script from the execution list.

EXAMPLES

    Execute default scripts:
        $(basename "$0")

    Dry-run:
        $(basename "$0") --dry-run

    Remove a default script:
        $(basename "$0") \\
            - .github/common/resources/install-cert-manager.sh

    Add a script:
        $(basename "$0") \\
            + .github/common/resources/install-cert-manager.sh

    Add a script with arguments:
        $(basename "$0") \\
            + .github/common/resources/configure-cluster.sh \\
                "node-role.kubernetes.io/infra=" \\
                "iam kube oauth2-proxy admin.iam"
EOF
}

add_script() {
    local script="$1"
    shift

    # Replace existing definition if already present
    remove_script "$script" 2>/dev/null || true

    SCRIPTS+=("$script")
    SCRIPT_ARGS["$script"]="$(printf '%s\n' "$@")"
}

remove_script() {
    local script="$1"

    local tmp=()

    for s in "${SCRIPTS[@]}"; do
        [[ "$s" != "$script" ]] && tmp+=("$s")
    done

    SCRIPTS=("${tmp[@]}")

    unset "SCRIPT_ARGS[$script]" || true
}

parse() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                shift
                ;;

            -h|--help)
                usage
                exit 0
                ;;

            +)
                shift

                [[ $# -gt 0 ]] || {
                    echo "Missing script after +"
                    exit 1
                }

                local script="$1"
                shift

                local args=()

                while [[ $# -gt 0 ]]; do
                    case "$1" in
                        +|-|--dry-run|-h|--help)
                            break
                            ;;
                        *)
                            args+=("$1")
                            shift
                            ;;
                    esac
                done

                add_script "$script" "${args[@]}"
                ;;

            -)
                shift

                [[ $# -gt 0 ]] || {
                    echo "Missing script after -"
                    exit 1
                }

                remove_script "$1"
                shift
                ;;

            *)
                echo "Unexpected argument: $1"
                exit 1
                ;;
        esac
    done
}

run() {
    for script in "${SCRIPTS[@]}"; do

        local argv=()

        while IFS= read -r arg; do
            [[ -n "$arg" ]] && argv+=("$arg")
        done <<< "${SCRIPT_ARGS[$script]}"

        if [[ "$DRY_RUN" == "true" ]]; then
            echo -n "Running:"
            printf ' "%s"' "$script" "${argv[@]}"
            echo
            continue
        fi

        "$script" "${argv[@]}"
    done
}

###############################################################################
# Default scripts
###############################################################################

add_script ".github/common/resources/remove-apps.sh"
add_script ".github/common/resources/patch-envoy.sh"
add_script ".github/common/resources/patch-nginx.sh"

###############################################################################
# Main
###############################################################################

if [[ $# -gt 0 ]]; then
    parse "$@"
fi

run
