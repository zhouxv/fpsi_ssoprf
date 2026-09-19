# Efficient Fuzzy Private Set Intersection from Secret-shared OPRF

This repository provides the implementation and build scripts for fuzzy private set intersection.

> Note: This project is experimental and primarily intended for research use. Adjust parameters according to your hardware and dataset sizes.

## Location of Main Functionality

- `src/*.cpp` contains the implementations of our building blocks such as `si-OPRF`, `so-OPRF`, `so-OPPRF` and other MPC components
- `src/fpsi.cpp` contains the implementations of basic `fuzzy mapping`, `fuzzy PSI` protocol
- `src/fpsi_prefix.cpp` contains the implementations of **prefix-optimized** `fuzzy mapping`, `fuzzy PSI` protocol

## Requirements

- Linux on **AMD64** Only
- `cmake`, `make`, `g++ 13`
- Docker (optional, for isolated builds)
- Additional third-party libraries [secure-join](https://github.com/Visa-Research/secure-join.git) and [volePSI](https://github.com/ladnir/volepsi.git) (can be installed by the scripts [install_securejoin.sh, install_volepsi.sh])

- **Dependencies :**

```bash
build-essential
cmake
git 
libtool 
iproute2 
python3 
sudo 
nasm 
libssl-dev 
libgmp-dev 
wget 
libfmt-dev
```

## Local build

From the project root directory:

```bash
./shell_install_dependencies.sh
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j

# The executable will be located at ./build/fpsi
```

## Docker (optional)

Use Docker for an isolated or reproducible build environment:

```bash
docker build -t fpsi_ssoprf .
docker tag fpsi_ssoprf:latest blueobsidian/fpsi_ssoprf:latest

docker run -it --name <your-container-name> --cap-add=NET_ADMIN --memory=512g <your-image-name>
docker run -dit --name fpsi_ssoprf --cap-add=NET_ADMIN fpsi_ssoprf:latest
docker pull blueobsidian/fpsi_ssoprf:latest

docker exec -it <your-container-name> bash
```

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


## Usage Examples

Run a basic fuzzy PSI experiment:

```bash
./build/fpsi -p 3 -m 0 -nn 8 -d 8 -delta 16 -v 1
```

Enable prefix optimization:

```bash
./build/fpsi -p 4 -m 0 -nn 8 -d 8 -delta 16 -v 1
```

Protocols `1` through `4` print online results with the following columns:

```text
[Protocol] [Metric] [Dim] [Delta] [Size] [Com.(MB)] [Online(s)]
```

Protocols `5` and `6` run only the offline preprocessing and print:

```text
[Protocol] [Dim] [Delta] [Size] [Offline(s)]
```

`Offline(s)` includes LocalMap/LocalMapPrefix, local PRF evaluation, and OKVS
encoding. Sender and receiver preprocessing pipelines run concurrently, so the
result is the wall-clock time until both parties finish. Synthetic input
generation is excluded. The offline phase performs no communication.

Use `-out` to append a result to a CSV file that Excel can open directly:

```bash
./build/fpsi -p 3 -m 0 -nn 8 -d 8 -delta 16 -out fpsi.csv
```

Run the non-prefix offline preprocessing independently:

```bash
./build/fpsi -p 5 -nn 12 -d 6 -delta 60 -try 3 -out fmap-offline.csv
```

------------------------------------------------------------------------

## Baseline Implementations

The following baseline implementations are used for comparison.

### Gao et al

[Code](https://github.com/ql70ql70/Fuzzy-Private-Set-Intersection-from-Fuzzy-Mapping) |   [Paper](https://eprint.iacr.org/2024/1462)

Recommended Docker image:

    blueobsidian/gao_artifact:latest

------------------------------------------------------------------------

### Dang et al

[Code](https://github.com/zhouxv/ourFuzzyPSI-C) | [Paper](https://eprint.iacr.org/2025/1796)

Recommended Docker image:

    blueobsidian/fpsi_artifact:latest

------------------------------------------------------------------------

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
