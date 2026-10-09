# Efficient Fuzzy Private Set Intersection from Secret-shared OPRF

This repository provides the implementation and build scripts for fuzzy private set intersection.

> Note: This project is experimental and primarily intended for research use. Adjust parameters according to your hardware and dataset sizes.

## Build and Run with Docker

Run the following from this repository's root directory, which contains the
`Dockerfile`. The build installs dependencies and compiles `build/fpsi`;
no prebuilt FPSI image is required.

```bash
docker build -t blueobsidian/fpsi_cmp_artifact:exp11_ssoprf .
docker run -d --cap-add=NET_ADMIN \
  --name fpsi_cmp_exp11 \
  blueobsidian/fpsi_cmp_artifact:exp11_ssoprf \
  sleep infinity
docker exec -it fpsi_cmp_exp11 bash
```

The container's project directory is `/workspace`, and the executable is
`/workspace/build/fpsi`. Run the benchmark commands below inside this
container. `NET_ADMIN` is needed for LAN/WAN network configuration. Building
requires internet access to download dependencies; pushing an image to a
registry is not required.

## Artifact comparison benchmarks (Exp11)

This is the so-OPPRF-based fuzzy PSI baseline (Exp11) for the comparison
artifact. The benchmark script uses the prefix-optimized protocol (`-p 4`).
Run the following from the project root after building the executable:

```bash
./shell_config_network.sh lan
./shell_run_bench_fpsi.sh
./shell_run_bench_fpsi.sh --preset full
```

Quick is the default and is equivalent to `--preset quick`. The presets
match the camera-ready comparison paper's thresholds:

| Parameter | Quick | Full |
|---|---|---|
| Metrics | Linf, L1, L2 | Linf, L1, L2 |
| Set size N | 2^12 | 2^8, 2^12, 2^16 |
| Dimension d | 2, 6, 10 | 2, 6, 10 |
| Threshold delta | 60, 250 | 60, 250 |
| Trials per combination | 1 | 3 |
| Combinations | 18 | 54 |

Both LAN (10 Gbps, no added delay) and WAN (100 Mbps, 80 ms target RTT) are
paper settings. Run Ours and both baselines under the same selected profile:

```bash
./shell_config_network.sh wan
./shell_run_bench_fpsi.sh --preset quick
./shell_run_bench_fpsi.sh --preset full
```

Use `./shell_run_bench_fpsi.sh --help` and `./shell_config_network.sh --help`
for options. Explicit experiment options override preset values, for example
`./shell_run_bench_fpsi.sh --preset full --nn 12 16`. Network configuration
requires root/sudo locally or `NET_ADMIN` in a container.


## Command-line Options

Below are the commonly used command-line flags. Flags use a leading dash (for example `-nn`, `-d`).

| Flag | Meaning | Values / Notes |
| --- | --- | --- |
| `-p` | Protocol | `1`: fuzzy mapping (default), `2`: prefix fuzzy mapping, `3`: fuzzy PSI, `4`: prefix fuzzy PSI, `5`: fuzzy mapping offline only, `6`: prefix fuzzy mapping offline only |
| `-d` | Dimension | positive integer; default `2` |
| `-m` | FPSI metric | `0`: $L_\infty$ (default), `1`: $L_1$, `2`: $L_2$; used by `-p 3/4` |
| `-delta` | Distance threshold (δ) | positive integer, default `10`; prefix protocols require matching entries in `include/param.h` |
| `-nn` | log2 of input set size (n) | default `8`; tested values: `8`~`16` |
| `-i` | Number of matching points | integer in `[0, set size]`; default `min(7, set size)` |
| `-v` | Verbosity | `0`: off (default), `1`: info |
| `-try` | Number of runs | integer, default `1` |
| `-out` | CSV result file | optional; no CSV is written when omitted |

## Acknowledgements

Parts of this codebase (for prefix optimization) are adapted from [zhouxv/ourFuzzyPSI-C](https://github.com/zhouxv/ourFuzzyPSI-C)

## Citation

If you make use of our work, please consider citing us:

```bibtex
@INPROCEEDINGS{
  title={Efficient fuzzy private set intersection from secret-shared OPRF},
  author={Yang, Xinpeng and Hao, Meng and Weng, Chenkai and Deng, Robert H and Wen, Yonggang and Zhang, Tianwei},
  booktitle={2026 IEEE Symposium on Security and Privacy (SP)},
  pages={2442--2461},
  year={2026},
  organization={IEEE}
}
```
