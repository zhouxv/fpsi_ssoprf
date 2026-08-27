#!/usr/bin/env bash
set -euo pipefail

# Fmap experiment script.
#
# Syntax:
#   ./bench_fmap.sh [options]
#
# Scalar options consume exactly one value:
#   -p <protocol>  -i <matching-points>  -try <count>  -out <file.csv>
#
# List options consume one or more values up to the next option:
#   -m <metrics...>  -nn <sizes...>  -d <dimensions...>  -delta <values...>
#
# Example:
#   ./bench_fmap.sh -nn 8 12 -d 2 6 -delta 10 60 -i 7 -try 3
#
# This script only expands the experiment matrix. The fpsi executable performs
# all value and compatibility checks and prints help for invalid arguments.

# Obtain the absolute path to this script, even if it is invoked via a symlink.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FPSI_BIN="${SCRIPT_DIR}/build/fpsi"

# Default experiment matrix. Command-line options replace these values.
protocol=1
metrics=(0 1 2)
ns=(8 12 16)
dims=(2 6 10 15)
deltas=(10 60 250)
matching_points=7
num_try=3
output_file=""

print_help() {
  cat <<EOF
Usage:
  ${0##*/} [-p protocol] [-m values...] [-nn values...] [-d values...]
             [-delta values...] [-i value] [-try value] [-out file.csv]

Defaults:
  p=1, m=(0 1 2), nn=(8 12 16), d=(2 6 10 15),
  delta=(10 60 250), i=7, try=3

Protocol: 1=fmap, 2=fmap-prefix, 3=fpsi, 4=fpsi-prefix
Metric:   0=Linf, 1=L1, 2=L2 (used only by p=3 and p=4)

Without -out, a timestamped CSV file is created beside this script.
EOF
}

# List parsing stops when the next token begins with '-'. Only the experiment
# options documented above are used to construct the matrix.
while [[ $# -gt 0 ]]; do
  case "$1" in
  -p) protocol="$2"; shift 2 ;;
  -m)
    shift
    metrics=()
    while [[ $# -gt 0 && "$1" != -* ]]; do metrics+=("$1"); shift; done
    ;;
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
  -out) output_file="$2"; shift 2 ;;
  -h | -help) print_help; exit 0 ;;
  *) shift ;;
  esac
done

# This is an environment check, not benchmark-parameter validation.
if [[ ! -x "${FPSI_BIN}" ]]; then
  echo "Benchmark binary not found or not executable: ${FPSI_BIN}" >&2
  exit 1
fi

# Each run uses one protocol because fmap and FPSI CSV files have different
# headers. The protocol name is included in the timestamped default filename.
if [[ -z "${output_file}" ]]; then
  case "${protocol}" in
  1) protocol_name="fmap" ;;
  2) protocol_name="fmap_prefix" ;;
  3) protocol_name="fpsi" ;;
  4) protocol_name="fpsi_prefix" ;;
  *) protocol_name="benchmark" ;;
  esac
  output_file="${SCRIPT_DIR}/${protocol_name}_results_$(date +%Y%m%d_%H%M%S).csv"
fi


printf "[Protocol] [Metric] [Dim] [Delta] [Size] [Com.(MB)] [Offline(s)] [Online(s)]\n"

# Run one point in the Cartesian product. Metrics are passed only to FPSI.
run_case() {
  local metric="$1" nn="$2" dim="$3" delta="$4"
  local args=(-p "${protocol}" -nn "${nn}" -d "${dim}" -delta "${delta}"
              -i "${matching_points}" -try "${num_try}" -out "${output_file}")
  if [[ "${protocol}" == 3 || "${protocol}" == 4 ]]; then
    args+=(-m "${metric}")
  fi
  "${FPSI_BIN}" "${args[@]}"
}

if [[ "${protocol}" == 1 || "${protocol}" == 2 ]]; then
  for nn in "${ns[@]}"; do
    for dim in "${dims[@]}"; do
      for delta in "${deltas[@]}"; do run_case 0 "${nn}" "${dim}" "${delta}"; done
    done
  done
else
  for metric in "${metrics[@]}"; do
    for nn in "${ns[@]}"; do
      for dim in "${dims[@]}"; do
        for delta in "${deltas[@]}"; do run_case "${metric}" "${nn}" "${dim}" "${delta}"; done
      done
    done
  done
fi

printf "Results written to %s\n" "${output_file}"
