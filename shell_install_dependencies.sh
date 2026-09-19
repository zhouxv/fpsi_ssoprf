#!/usr/bin/env bash
set -euo pipefail

install_volepsi() {
    ## Build volePSI
git clone https://github.com/ladnir/volepsi.git
cd volepsi
git checkout 59e06bca81a3287257522cd261bad71e37780642
sed -i 's|36cd7242e085eddba34feaa63733ec4c6ded66c7|d21bc4d7aae941e276b92615252fd1760c902890|g' thirdparty/getLibOTe.cmake

# Download boost 1.86.0, because the automatic download source of the library is too slow
mkdir -p out && cd out
curl -fL --retry 3 \
-o boost_1_86_0.tar.bz2 \
'https://sourceforge.net/projects/boost/files/boost/1.86.0/boost_1_86_0.tar.bz2/download'
cd ..

python3 build.py --install=../out/install -DVOLE_PSI_ENABLE_BOOST=true -DVOLE_PSI_ENABLE_BITPOLYMUL=false -DVOLE_PSI_SODIUM_MONTGOMERY=false -DCMAKE_PREFIX_PATH=/usr/local/
cp ./out/build/linux/volePSI/config.h ../out/install/include/volePSI
cd ..
rm -rf volepsi

}

install_securejoin() {
    ## Build secure-join
git clone https://github.com/Visa-Research/secure-join.git
cd secure-join
git checkout df62f360df0c2dfb8288f8f7b99ccf3472318e87
sed -i 's|set(GIT_TAG             "657f6da90bff5774a2d01c824e997572d5e8ba00")|set(GIT_TAG             "d21bc4d7aae941e276b92615252fd1760c902890")|' thirdparty/getLibOTe.cmake

# Download boost 1.86.0, because the automatic download source of the library is too slow
mkdir -p out && cd out
curl -fL --retry 3 \
-o boost_1_86_0.tar.bz2 \
'https://sourceforge.net/projects/boost/files/boost/1.86.0/boost_1_86_0.tar.bz2/download'
cd ..

python3 build.py --install=../out/install -D SECUREJOIN_ENABLE_BOOST=ON -D SODIUM_MONTGOMERY=false -D ENABLE_BITPOLYMUL=false 
cd ..
rm -rf secure-join
}


mkdir -p thirdparty && cd thirdparty

install_volepsi
install_securejoin