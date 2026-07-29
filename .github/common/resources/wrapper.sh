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

add_script() {
    local script="$1"
    shift

    SCRIPTS+=("$script")

    # Store arguments separated by newlines to preserve spaces
    SCRIPT_ARGS["$script"]="$(printf '%s\n' "$@")"
}

remove_script() {
    local script="$1"

    local tmp=()

    for s in "${SCRIPTS[@]}"; do
        [[ "$s" != "$script" ]] && tmp+=("$s")
    done

    SCRIPTS=("${tmp[@]}")

    unset SCRIPT_ARGS["$script"] || true
}

parse() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                shift
                ;;

            +)
                shift

                [[ $# -gt 0 ]] || {
                    echo "Missing script after +"
                    exit 1
                }

                script="$1"
                shift

                args=()

                while [[ $# -gt 0 ]]; do
                    case "$1" in
                        +|-|--dry-run)
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

        declare -a argv=()

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

parse "$@"
run
