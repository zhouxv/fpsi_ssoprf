#!/usr/bin/env bash
set -euo pipefail

# Standalone benchmark for fmap offline preprocessing (protocol 5).
#
# Syntax:
#   ./bench_fmap_offline.sh [options]
#
# Scalar options consume one value:
#   -p <protocol>  -try <count>  -out <file.csv>
#
# List options consume one or more values up to the next option:
#   -nn <sizes...>  -d <dimensions...>  -delta <values...>
#
# Example:
#   ./bench_fmap_offline.sh -nn 8 12 -d 2 6 -delta 10 60 -try 3
#
# The script only expands the experiment matrix. The executable validates all
# parameter values. Without -out, the timestamped CSV is written beside this
# script in the project root.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FPSI_BIN="${SCRIPT_DIR}/build/fpsi"

protocol=5
ns=(8 12 16)
dims=(2 6 10 15)
deltas=(10 60 250)
num_try=3
output_file=""

print_help() {
  cat <<EOF
Usage:
  ${0##*/} [-p protocol] [-nn values...] [-d values...]
             [-delta values...] [-try value] [-out file.csv]

Defaults:
  p=5, nn=(8 12 16), d=(2 6 10 15),
  delta=(10 60 250), try=3

Offline protocols: 5=fmap-offline, 6=fmap-prefix-offline
Without -out, a timestamped CSV file is created beside this script.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -p) protocol="$2"; shift 2 ;;
  -nn) shift; ns=(); while [[ $# -gt 0 && "$1" != -* ]]; do ns+=("$1"); shift; done ;;
  -d) shift; dims=(); while [[ $# -gt 0 && "$1" != -* ]]; do dims+=("$1"); shift; done ;;
  -delta) shift; deltas=(); while [[ $# -gt 0 && "$1" != -* ]]; do deltas+=("$1"); shift; done ;;
  -try) num_try="$2"; shift 2 ;;
  -out) output_file="$2"; shift 2 ;;
  -h | -help) print_help; exit 0 ;;
  *) shift ;;
  esac
done

if [[ ! -x "${FPSI_BIN}" ]]; then
  echo "Experiment binary not found or not executable: ${FPSI_BIN}" >&2
  exit 1
fi

if [[ -z "${output_file}" ]]; then
  case "${protocol}" in
  1) protocol_name="fmap" ;; 2) protocol_name="fmap_prefix" ;;
  3) protocol_name="fpsi" ;; 4) protocol_name="fpsi_prefix" ;;
  5) protocol_name="fmap_offline" ;; 6) protocol_name="fmap_prefix_offline" ;;
  *) protocol_name="benchmark" ;;
  esac
  output_file="${SCRIPT_DIR}/${protocol_name}_results_$(date +%Y%m%d_%H%M%S).csv"
fi

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
