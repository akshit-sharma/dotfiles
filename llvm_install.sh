#!/bin/bash

set -e
#set -x

version=""

while getopts v: flag
do
  case "${flag}" in
    v) version=${OPTARG};;
  esac
done

if [ -n "$version" ]; then
  echo "Installing LLVM version $version"
else
  echo "No version specified"
  echo "usage: ./llvm_install.sh -v <version>"
  exit 1
fi

sudo apt install -y ninja-build

pushd /tmp
if [ -d "llvm-project" ]; then
  rm -rf llvm-project
fi
git clone https://github.com/llvm/llvm-project.git --depth 1 --branch release/$version.x
pushd llvm-project
cmake -S llvm -B build -G Ninja -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;libc;lld;lldb;mlir;openmp" -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind;compiler-rt" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
sudo cmake --install build

exit 0

pushd /tmp
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh $version all

if [ -n "$version" ]; then
  LLVMFILES=/usr/bin/llvm-*-$version
  CLANGFILES=/usr/bin/clang*-$version
  for file in $LLVMFILES $CLANGFILES
  do
    suffix_length=$(echo "-$version" | wc -c)
    suffix_length=$((suffix_length-1))
    link=${file::-$suffix_length}
    if [ -f "$link" ]; then
      echo "Removing $link"
      sudo rm $link
    fi
    echo "Creating link $link -> $file"
    sudo ln -s $file $link
  done
  # if /usr/lib/x86_64-linux-gnu/libstdc++.so not exists
  # then take latest version from /usr/lib/x86_64-linux-gnu/libstdc++.so.*
  # and create link /usr/lib/x86_64-linux-gnu/libstdc++.so -> libstdc++.so.*
  if [ ! -f "/usr/lib/x86_64-linux-gnu/libstdc++.so" ]; then
    libstdcppfiles=/usr/lib/x86_64-linux-gnu/libstdc++.so.*
    latest_libstdcppfile=$(ls -t $libstdcppfiles | head -1)
    echo "Creating link /usr/lib/x86_64-linux-gnu/libstdc++.so -> $latest_libstdcppfile"
    sudo ln -s $latest_libstdcppfile /usr/lib/x86_64-linux-gnu/libstdc++.so
  fi
fi

