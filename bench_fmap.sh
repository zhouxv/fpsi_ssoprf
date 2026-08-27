#!/usr/bin/env bash
set -euo pipefail

# Fmap experiment script.
#
# Syntax:
#   ./bench_fmap.sh [options]
#
# Scalar options consume exactly one value:
#   -i <matching-points>  -try <count>
#
# List options consume one or more values up to the next option:
#   -nn <sizes...>  -d <dimensions...>  -delta <values...>
#
# Example:
#   ./bench_fmap.sh -nn 8 12 -d 2 6 -delta 10 60 -i 7 -try 3
#
# This script only expands the experiment matrix. The fpsi executable performs
# all value and compatibility checks and prints help for invalid arguments.
# Protocol 1 is fixed, and every invocation creates a timestamped CSV beside
# this script; users do not select a protocol or output path here.

# Obtain the absolute path to this script, even if it is invoked via a symlink.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FPSI_BIN="${SCRIPT_DIR}/build/fpsi"

# Default experiment matrix. Command-line options replace these values.
protocol=1
ns=(8 12 16)
dims=(2 6 10 15)
deltas=(10 60 250)
matching_points=7
num_try=3

print_help() {
  cat <<EOF
Usage:
  ${0##*/} [-nn values...] [-d values...] [-delta values...]
             [-i value] [-try value]

Defaults:
  protocol=1 (fmap), nn=(8 12 16), d=(2 6 10 15),
  delta=(10 60 250), i=7, try=3

A timestamped CSV file is always created beside this script.
EOF
}

# List parsing stops when the next token begins with '-'. Only the experiment
# options documented above are used to construct the matrix.
while [[ $# -gt 0 ]]; do
  case "$1" in
  -nn)
    shift
    ns=()
    while [[ $# -gt 0 && "$1" != -* ]]; do ns+=("$1"); shift; done
    ;;
  -d)
    shift
    dims=()
    while [[ $# -gt 0 && "$1" != -* ]]; do dims+=("$1"); shift; done
    ;;
  -delta)
    shift
    deltas=()
    while [[ $# -gt 0 && "$1" != -* ]]; do deltas+=("$1"); shift; done
    ;;
  -i) matching_points="$2"; shift 2 ;;
  -try) num_try="$2"; shift 2 ;;
  -h | -help) print_help; exit 0 ;;
  *) shift ;;
  esac
done

# This is an environment check, not benchmark-parameter validation.
if [[ ! -x "${FPSI_BIN}" ]]; then
  echo "Benchmark binary not found or not executable: ${FPSI_BIN}" >&2
  exit 1
fi

# Use a protocol-specific filename so this CSV cannot be mixed with a different
# result schema by selecting a user-provided output path.
output_file="${SCRIPT_DIR}/fmap_results_$(date +%Y%m%d_%H%M%S).csv"

printf "[Protocol] [Metric] [Dim] [Delta] [Size] [Com.(MB)] [Online(s)]\n"

# Run one point in the fmap experiment matrix.
run_case() {
  local nn="$1" dim="$2" delta="$3"
  local args=(-p "${protocol}" -nn "${nn}" -d "${dim}" -delta "${delta}"
              -i "${matching_points}" -try "${num_try}" -out "${output_file}")
  "${FPSI_BIN}" "${args[@]}"
}

for nn in "${ns[@]}"; do
  for dim in "${dims[@]}"; do
    for delta in "${deltas[@]}"; do
      run_case "${nn}" "${dim}" "${delta}"
    done
  done
done

printf "Results written to %s\n" "${output_file}"
