mkdir -p thirdparty
cd thirdparty

## Build secure-join
git clone https://github.com/Visa-Research/secure-join.git
cd secure-join
sed -i 's|set(GIT_TAG             "657f6da90bff5774a2d01c824e997572d5e8ba00")|set(GIT_TAG             "d21bc4d7aae941e276b92615252fd1760c902890")|' thirdparty/getLibOTe.cmake
python3 build.py --install=../out/install -D SECUREJOIN_ENABLE_BOOST=ON -D SODIUM_MONTGOMERY=false -D ENABLE_BITPOLYMUL=false 
cd ..
rm -rf secure-join

cd ..
