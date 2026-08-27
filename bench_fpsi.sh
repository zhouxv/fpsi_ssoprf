#!/usr/bin/env bash
set -euo pipefail

# FPSI experiment script.
#
# Scalar syntax: -i <matching-points> -try <count>
# List syntax:   -m <values...> -nn <values...> -d <values...>
#                -delta <values...>
# A list ends when the next token beginning with '-' is encountered.
# Example: ./bench_fpsi.sh -m 0 1 -nn 8 12 -d 2 6 -delta 10 60 -i 7
#
# The script builds the experiment matrix only. Argument validation belongs to
# the fpsi executable so every entry point follows the same validation rules.
# Protocol 3 is fixed, and every invocation creates a timestamped CSV beside
# this script; users do not select a protocol or output path here.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FPSI_BIN="${SCRIPT_DIR}/build/fpsi"

# Defaults can be replaced by the command-line options documented above.
protocol=3
metrics=(0 1 2)
ns=(8 12 16)
dims=(2 6 10 15)
deltas=(10 60 250)
matching_points=7
num_try=3

print_help() {
  cat <<EOF
Usage:
  ${0##*/} [-m values...] [-nn values...] [-d values...]
             [-delta values...] [-i value] [-try value]

Defaults: protocol=3 (fpsi), m=(0 1 2), nn=(8 12 16), d=(2 6 10 15),
          delta=(10 60 250), i=7, try=3
Metric:   0=Linf, 1=L1, 2=L2

A timestamped CSV file is always created beside this script.
EOF
}

# Parse only the options used to construct the experiment matrix.
while [[ $# -gt 0 ]]; do
  case "$1" in
  -m) shift; metrics=(); while [[ $# -gt 0 && "$1" != -* ]]; do metrics+=("$1"); shift; done ;;
  -nn) shift; ns=(); while [[ $# -gt 0 && "$1" != -* ]]; do ns+=("$1"); shift; done ;;
  -d) shift; dims=(); while [[ $# -gt 0 && "$1" != -* ]]; do dims+=("$1"); shift; done ;;
  -delta) shift; deltas=(); while [[ $# -gt 0 && "$1" != -* ]]; do deltas+=("$1"); shift; done ;;
  -i) matching_points="$2"; shift 2 ;;
  -try) num_try="$2"; shift 2 ;;
  -h | -help) print_help; exit 0 ;;
  *) shift ;;
  esac
done

# Check only the build artifact; the executable checks benchmark arguments.
if [[ ! -x "${FPSI_BIN}" ]]; then
  echo "Benchmark binary not found or not executable: ${FPSI_BIN}" >&2
  exit 1
fi

# Use a protocol-specific filename and keep every result beside this script.
output_file="${SCRIPT_DIR}/fpsi_results_$(date +%Y%m%d_%H%M%S).csv"

printf "[Protocol] [Metric] [Dim] [Delta] [Size] [Com.(MB)] [Online(s)]\n"

# Execute one Cartesian-product entry and append its row to the same CSV file.
run_case() {
  local metric="$1" nn="$2" dim="$3" delta="$4"
  local args=(-p "${protocol}" -nn "${nn}" -d "${dim}" -delta "${delta}"
              -i "${matching_points}" -try "${num_try}" -m "${metric}"
              -out "${output_file}")
  "${FPSI_BIN}" "${args[@]}"
}

for metric in "${metrics[@]}"; do for nn in "${ns[@]}"; do
  for dim in "${dims[@]}"; do for delta in "${deltas[@]}"; do
    run_case "${metric}" "${nn}" "${dim}" "${delta}"
  done; done
done; done

printf "Results written to %s\n" "${output_file}"
