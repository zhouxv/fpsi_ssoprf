#!/usr/bin/env bash
set -euo pipefail

# Standalone benchmark for prefix-fmap offline preprocessing (protocol 6).
#
# Syntax:
#   ./bench_fmap_prefix_offline.sh [options]
#
# Scalar options consume one value:
#   -try <count>
#
# List options consume one or more values up to the next option:
#   -nn <sizes...>  -d <dimensions...>  -delta <values...>
#
# Example:
#   ./bench_fmap_prefix_offline.sh -nn 8 12 -d 2 6 -delta 10 60 -try 3
#
# The script only expands the experiment matrix. The executable validates all
# parameter values. Protocol 6 is fixed, and the timestamped CSV is always
# written beside this script in the project root.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FPSI_BIN="${SCRIPT_DIR}/build/fpsi"

protocol=6
ns=(8 12 16)
dims=(2 6 10 15)
deltas=(10 60 250)
num_try=3

print_help() {
  cat <<EOF
Usage:
  ${0##*/} [-nn values...] [-d values...] [-delta values...] [-try value]

Defaults:
  protocol=6 (fmap-prefix-offline), nn=(8 12 16), d=(2 6 10 15),
  delta=(10 60 250), try=3

A timestamped CSV file is always created beside this script.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -nn) shift; ns=(); while [[ $# -gt 0 && "$1" != -* ]]; do ns+=("$1"); shift; done ;;
  -d) shift; dims=(); while [[ $# -gt 0 && "$1" != -* ]]; do dims+=("$1"); shift; done ;;
  -delta) shift; deltas=(); while [[ $# -gt 0 && "$1" != -* ]]; do deltas+=("$1"); shift; done ;;
  -try) num_try="$2"; shift 2 ;;
  -h | -help) print_help; exit 0 ;;
  *) shift ;;
  esac
done

if [[ ! -x "${FPSI_BIN}" ]]; then
  echo "Experiment binary not found or not executable: ${FPSI_BIN}" >&2
  exit 1
fi

# Use a fixed protocol-specific output name; users cannot redirect script
# results into a CSV with a different schema.
output_file="${SCRIPT_DIR}/fmap_prefix_offline_results_$(date +%Y%m%d_%H%M%S).csv"

printf "[Protocol] [Dim] [Delta] [Size] [Offline(s)]\n"

for nn in "${ns[@]}"; do
  for dim in "${dims[@]}"; do
    for delta in "${deltas[@]}"; do
      "${FPSI_BIN}" -p "${protocol}" -nn "${nn}" -d "${dim}" \
        -delta "${delta}" -try "${num_try}" -out "${output_file}"
    done
  done
done

printf "Results written to %s\n" "${output_file}"
