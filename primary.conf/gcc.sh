#!/bin/bash
#

GCC_SCRIPT_PATH=""
function parent_dir {
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was
          located
  done
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  GCC_SCRIPT_PATH=$DIR
}

GCC_TEMP_DIR=$GCC_SCRIPT/../gcc

if [ ! -f $GCC_TEMP_DIR/gcc.done ]; then

  parent_dir

  GCC_SRC_HOME=$HOME/Libraries/gcc-from-src
  GCC_BIN_HOME=$HOME/Softwares/gcc

  if [ -d $GCC_TEMP_DIR ]; then
    GCC_TEMP_DIR=$GCC_TEMP_DIR
  else
    mkdir -p /tmp/gcc_script
    GCC_TEMP_DIR=/tmp/gcc_script
  fi

  GCC_CORRECT_MD5="6a1fabd167fe98c11857181c210fc743"
  GCC_VERSION="8.1"
  GCC_TAR_DIR="gcc-$GCC_VERSION.0"
  GCC_TAR_GZ="$GCC_TAR_DIR.tar.gz"
  GCC_TAR_URL="https://ftpmirror.gnu.org/gcc/$GCC_TAR_DIR/$GCC_TAR_GZ"

  if [ ! -d $GCC_SRC_HOME ]; then
    mkdir -p $GCC_SRC_HOME
  fi
  if [ ! -d  "$GCC_BIN_HOME" ]; then
    if [ ! -f "$GCC_TEMP_DIR/$GCC_TAR_GZ" ]; then # download if file not found
      echo "downloading $GCC_SCRIPT_PATH/../$GCC_TAR_GZ"
      wget $GCC_TAR_URL -O $GCC_TEMP_DIR/$GCC_TAR_GZ
    else
      GCC_DOWNLOAD_MD5=`eval md5sum $GCC_TEMP_DIR/$GCC_TAR_GZ | cut -d' ' -f1`
      if [ "$GCC_CORRECT_MD5" != "$GCC_DOWNLOAD_MD5" ]; then  # download if previous was corrupt
        echo "redownloading gcc $GCC_TEMP_DIR/$GCC_TAR_GZ"
        rm $GCC_TEMP_DIR/$GCC_TAR_GZ
        wget $GCC_TAR_URL -O $GCC_TEMP_DIR/$GCC_TAR_GZ
      fi
    fi
    if [ -d "$GCC_SRC_HOME/$GCC_TAR_DIR" ]; then
      rm -rf $GCC_SRC_HOME/$GCC_TAR_DIR
    fi
    tar -xf $GCC_TEMP_DIR/$GCC_TAR_GZ -C $GCC_SRC_HOME
  else                                                       # check for update in script
    GCC_DOWNLOAD_MD5=`eval md5sum $GCC_TEMP_DIR/$GCC_TAR_GZ | cut -d' ' -f1`
    if [ "$GCC_CORRECT_MD5" != "$GCC_DOWNLOAD_MD5" ]; then
      echo "downloading new version of gcc"
      rm $GCC_TEMP_DIR/$GCC_TAR_GZ
      wget $GCC_TAR_URL -O $GCC_TEMP_DIR/$GCC_TAR_GZ
      if [ -d $GCC_SRC_HOME/$GCC_TAR_DIR ]; then
        rm -rf $GCC_SRC_HOME/$GCC_TAR_DIR
      fi
      if [ -f "$GCC_TEMP_DIR/.gcc-prerequisites.md5" ]; then
        rm $GCC_TEMP_DIR/.gcc-prerequisites.md5
      fi
      if [ -d "$GCC_SRC_HOME/$GCC_TAR_DIR" ]; then
        rm -rf $GCC_SRC_HOME/$GCC_TAR_DIR
      fi
      tar -xf $GCC_TEMP_DIR/$GCC_TAR_GZ -C $GCC_SRC_HOME
    else
      echo "$GCC_TEMP_DIR/$GCC_TAR_GZ up-to-date"
    fi
  fi
  if [ ! -f "$GCC_TEMP_DIR/.gcc-prerequisites.md5" ]; then
    cd $GCC_SRC_HOME/$GCC_TAR_DIR
    ./contrib/download_prerequisites
    if [ "$?" != 0 ]; then
      echo "Error downloading prerequisites for gcc"
      exit 1 
    fi
    GCC_DOWNLOAD_PREREQUISITES_MD5=`eval md5sum contrib/download_prerequisites | cut -d' ' -f1`
    echo $GCC_DOWNLOAD_PREREQUISITES_MD5 > $GCC_TEMP_DIR/.gcc-prerequisites.md5 
    if [ -f "$GCC_TEMP_DIR/.gcc-build" ]; then
      rm $GCC_TEMP_DIR/.gcc-build
    fi
    cd $GCC_SCRIPT_PATH
  fi
  if [ ! -f "$GCC_TEMP_DIR/.gcc-build" ]; then
    cd $GCC_SRC_HOME/
    if [ ! -d build ]; then
      mkdir build
    fi
    cd build
    ../$GCC_TAR_DIR/configure -v --build=x86_64-linux-gnu --host=x86_64-linux-gnu \
                  target=x86_64-linux-gnu --prefix=$GCC_BIN_HOME --enable-checking=release \
                  --enable-languages=c,c++ --disable-multilib --program-suffix=-$GCC_VERSION
    for ((i=16; i >= 1; i = i/2))
    do
      echo "Running with $i jobs"
      make -j $i
      if [ $? -ne 0 ] && [ $i -eq 1 ]; then
        echo "Error in running with 1 job"
        echo "Returning"
        exit 2
      fi
    done 
    make install
    cd ..
    rm -rf build # remove build intermediate results
    rm -rf $GCC_SRC_HOME/$GCC_TAR_DIR # remove extracted dir
    touch $GCC_TEMP_DIR/.gcc-build
    cd $GCC_SCRIPT_PATH
  fi

  touch $GCC_TEMP_DIR/gcc.done 

fi
