#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Prefix-FPSI benchmark runner
#
# Usage:
#   ./shell_run_bench_fpsi.sh quick
#   ./shell_run_bench_fpsi.sh full
#
# Default:
#   full
#
# Protocol:
#   p = 4 (fpsi-prefix)
#
# Metric:
#   0 = Linf
#   1 = L1
#   2 = L2
# ============================================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

FPSI_BIN="${SCRIPT_DIR}/build/fpsi"
NETWORK_SCRIPT="${SCRIPT_DIR}/shell_config_network.sh"

protocol=4
matching_points=7
interface="lo"

mode="${1:-full}"

# ============================================================
# Select benchmark mode.
# ============================================================

case "${mode}" in
  quick)
    metrics=(0 1 2)
    ns=(12)
    dims=(2 6 10)
    deltas=(10 250)
    num_try=1
    ;;

  full)
    metrics=(0 1 2)
    ns=(8 12 16)
    dims=(2 6 10)
    deltas=(10 60 250)
    num_try=3
    ;;

  -h|--help)
    cat <<EOF
Usage:
  ${0##*/} [quick|full]

Modes:

  quick
    metric = 0 1 2
    nn     = 12
    dim    = 2 6 10
    delta  = 10 250
    try    = 1

    Total:
      3 x 1 x 3 x 2 = 18 cases

  full
    metric = 0 1 2
    nn     = 8 12 16
    dim    = 2 6 10
    delta  = 10 60 250
    try    = 3

    Total:
      3 x 3 x 3 x 3 = 81 cases

Examples:

  ./shell_run_bench_fpsi.sh quick

  ./shell_run_bench_fpsi.sh full

EOF
    exit 0
    ;;

  *)
    echo "Error: invalid mode '${mode}'." >&2
    echo "Expected: quick or full" >&2
    echo >&2
    echo "Usage:" >&2
    echo "  ${0##*/} [quick|full]" >&2
    exit 1
    ;;
esac

# ============================================================
# Check benchmark binary.
# ============================================================

if [[ ! -x "${FPSI_BIN}" ]]; then
  echo "Error: benchmark binary not found or not executable:" >&2
  echo "  ${FPSI_BIN}" >&2
  echo >&2
  echo "Build the project first." >&2
  exit 1
fi

# ============================================================
# Read current network configuration.
#
# shell_config_network.sh changes the network environment.
# This script only reads the metadata.
# ============================================================

network_profile="unknown"
network_interface="${interface}"
bandwidth="unknown"
rtt="unknown"

if [[ -x "${NETWORK_SCRIPT}" ]]; then
  network_metadata="$(
    "${NETWORK_SCRIPT}" metadata --interface "${interface}" 2>/dev/null || true
  )"

  if [[ -n "${network_metadata}" ]]; then
    IFS=$'\t' read -r \
      network_profile \
      network_interface \
      bandwidth \
      rtt \
      <<< "${network_metadata}"
  fi
fi

# ============================================================
# Benchmark information.
# ============================================================

case_count=$((
  ${#metrics[@]} *
  ${#ns[@]} *
  ${#dims[@]} *
  ${#deltas[@]}
))

timestamp="$(date +%Y%m%d_%H%M%S)"

output_file="${SCRIPT_DIR}/fpsi_prefix_${mode}_${network_profile}_${timestamp}.csv"

echo "Prefix-FPSI Benchmark"
echo "Protocol : ${protocol}"
echo "Mode     : ${mode}"
echo "Metric   : ${metrics[*]}"
echo "nn       : ${ns[*]}"
echo "Dim      : ${dims[*]}"
echo "Delta    : ${deltas[*]}"
echo "Try      : ${num_try}"
echo "Cases    : ${case_count}"
echo "Network  : ${network_profile}"
echo "Rate     : ${bandwidth}"
echo "RTT      : ${rtt}"
echo "Output   : ${output_file}"
echo

# ============================================================
# Result header.
#
# Each following benchmark result should occupy exactly one line.
# ============================================================

printf '%s\n' \
  "[Protocol] [Metric] [Dim] [Delta] [Size] [Offline_Com.(MB)] [Offline(s)] [Online_Com.(MB)] [Online(s)] [Total_Com.(MB)] [Total(s)]"

# ============================================================
# Run benchmark matrix.
# ============================================================

for metric in "${metrics[@]}"; do
  for nn in "${ns[@]}"; do
    for dim in "${dims[@]}"; do
      for delta in "${deltas[@]}"; do

        "${FPSI_BIN}" \
          -p "${protocol}" \
          -m "${metric}" \
          -nn "${nn}" \
          -d "${dim}" \
          -delta "${delta}" \
          -i "${matching_points}" \
          -try "${num_try}" \
          -out "${output_file}"

      done
    done
  done
done

# ============================================================
# Done.
# ============================================================

echo
echo "Results written to: ${output_file}"