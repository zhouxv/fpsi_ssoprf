mkdir -p thirdparty
cd thirdparty

## Build volePSI
git clone https://github.com/ladnir/volepsi.git
cd volepsi
git checkout 59e06bca81a3287257522cd261bad71e37780642
sed -i 's|36cd7242e085eddba34feaa63733ec4c6ded66c7|d21bc4d7aae941e276b92615252fd1760c902890|g' thirdparty/getLibOTe.cmake
python3 build.py --install=../out/install -DVOLE_PSI_ENABLE_BOOST=true -DVOLE_PSI_ENABLE_BITPOLYMUL=false -DVOLE_PSI_SODIUM_MONTGOMERY=false -DCMAKE_PREFIX_PATH=/usr/local/
cp ./out/build/linux/volePSI/config.h ../out/install/include/volePSI
cd ..
rm -rf volepsi

cd ..
