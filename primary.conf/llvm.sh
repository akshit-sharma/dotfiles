#!/bin/bash
#

LLVM_SCRIPT_PATH=""
function parent_dir {
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was
          located
  done
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  LLVM_SCRIPT_PATH=$DIR
}

function svn_checkout {
  svn_link="$1"
  svn_dir="$2"

  if [ ! -d $svn_dir ]; then
    echo "creating svn directory $svn_dir from $svn_link" 
    svn co $svn_link $svn_dir
  else
    echo "updating svn directory $svn_dir"
    svn update $svn_dir
  fi
}

if [ ! -f $LLVM_SCRIPT_PATH/../faaltu/llvm.done ]; then

  parent_dir

  svn --version
  SVN_RET=$?

  make --version
  MAKE_RET=$?

  gcc --version
  GCC_RET=$?

  python --version
  PYTHON_RET=$?

  doxygen --version
  DOXYGEN_RET=$?

  sphinx --version
  SPHINX_RET=$?

  if [[ $SVN_RET -ne 0 ]] || [[ $MAKE_RET -ne 0 ]] || [[ $GCC_RET -ne 0 ]] || [[ $PYTHON_RET -ne 0 ]] || [[ $DOXYGEN_RET -ne 0 ]] || [[ $SPHINX_RET -ne 0 ]]; then
    CMD="sudo apt-get install -y "
    ORG_CMD="sudo apt-get install -y "
    # CMD="sudo apt-get install -y subversion make gcc python doxygen"
    if [[ $SVN_RET -ne 0 ]]; then
      CMD="$CMD subversion"
    fi
    if [[ $MAKE_RET -ne 0 ]]; then
      CMD="$CMD make"
    fi
    if [[ $GCC_RET -ne 0 ]]; then
      CMD="$CMD gcc"
    fi
    if [[ $PYTHON_RET -ne 0 ]]; then
      CMD="$CMD python"
    fi
    if [[ $DOXYGEN_RET -ne 0 ]]; then
      CMD="$CMD doxygen"
    fi
    if [[ $SPHINX_RET -ne 0 ]]; then
      pip install -U sphinx
      pip3 install -U sphinx
    fi
    if [ $CMD != $ORG_CMD ]; then
      echo $CMD
      $CMD
      CMD_RET=$?
      if [[ $CMD_RET -ne 0 ]]; then
        echo "Error in installing requirements"
        echo "Returning"
        exit 1
      fi
    fi
  fi

  if [ ! -d $LLVM_SCRIPT_PATH/../faaltu/clang+llvm/bin ]; then
    echo "installation of clang+llvm not found in clang+llvm of faaltu dir"
    exit 3
  fi


  LLVM_SRC_HOME=$HOME/Libraries/llvm-from-src
  LLVM_BIN_HOME=$HOME/Softwares/llvm

  svn_checkout http://llvm.org/svn/llvm-project/llvm/trunk $LLVM_SRC_HOME/llvm
  svn_checkout http://llvm.org/svn/llvm-project/cfe/trunk $LLVM_SRC_HOME/llvm/tools/clang
  svn_checkout http://llvm.org/svn/llvm-project/clang-tools-extra/trunk $LLVM_SRC_HOME/llvm/tools/clang/tools/extra
  svn_checkout http://llvm.org/svn/llvm-project/lld/trunk $LLVM_SRC_HOME/llvm/tools/lld
  svn_checkout http://llvm.org/svn/llvm-project/polly/trunk $LLVM_SRC_HOME/llvm/tools/polly
  svn_checkout http://llvm.org/svn/llvm-project/compiler-rt/trunk $LLVM_SRC_HOME/llvm/projects/compiler-rt
  svn_checkout http://llvm.org/svn/llvm-project/openmp/trunk $LLVM_SRC_HOME/llvm/projcets/openmp
  svn_checkout http://llvm.org/svn/llvm-project/libcxx/trunk $LLVM_SRC_HOME/llvm/projects/libcxx
  svn_checkout http://llvm.org/svn/llvm-project/libcxxabi/trunk $LLVM_SRC_HOME/llvm/projects/libcxxabi
  svn_checkout http://llvm.org/svn/llvm-project/test-suite/trunk $LLVM_SRC_HOME/llvm/projects/test-suite

  if [ ! -d $LLVM_BIN_HOME ]; then
    mkdir -p $LLVM_BIN_HOME
  fi 
  
  SYSTEM_CORES=`grep -c ^processor /proc/cpuinfo`
  SYSTEM_MEMORY=`grep MemTotal /proc/meminfo | awk '{print $2}'`

  if [ ! -d $LLVM_SRC_HOME/build-release ]; then
    mkdir $LLVM_SRC_HOME/build-release
    cd $LLVM_SRC_HOME/build-release 
    cmake -G "Unix Makefiles" -D CMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=$LLVM_BIN_HOME/llvm ../llvm \
              -DLLVM_ENABLE_SPHINX=true \
              -DSPHINX_OUTPUT_HTML=true
              # -DLLVM_ENABLE_DOXYGEN=true
              # -DCMAKE_C_COMPILER=$LLVM_SCRIPT_PATH/../faaltu/clang+llvm/bin/clang \
              # -DCMAKE_CXX_COMPILER=$LLVM_SCRIPT_PATH/../faaltu/clang+llvm/bin/clang++ \
              # -DLLVM_BUILD_LLVM_DYLIB=ON                                              \
              # -DLLVM_LINK_LLVM_DYLIB=ON    
    CMAKE_RET="$?"
    if [ $CMAKE_RET -ne 0 ]; then
      echo "Error running cmake command"
      echo "cmake return code : $CMAKE_RET"
      echo "removing $LLVM_SRC_HOME/build-release"
      rm -rf $LLVM_SRC_HOME/build-release
      exit 5
    fi
  fi
  SYSTEM_JOBS_ACCORDING_TO_MEMORY=$((SYSTEM_MEMORY / 2000000 ))
  SYSTEM_JOBS=$(($SYSTEM_JOBS_ACCORDING_TO_MEMORY>$SYSTEM_CORES?$SYSTEM_CORES:$SYSTEM_JOBS_ACCORDING_TO_MEMORY))
  for ((i=$SYSTEM_JOBS; i >= 1; i = i/2))
  do
    echo "Running with $i jobs"
    make -j $i
    MAKE_RET=$?
    if [ $MAKE_RET -eq 0 ]; then
      echo "make successful with $i jobs"
      break 
    fi
  done
  if [ $MAKE_RET -ne 0 ]; then
    echo "Error in running with 1 job"
    echo "Returning"
    exit 2
  fi
  make install
  MAKE_INSTALL_RET="$?"
  if [ $MAKE_INSTALL_RET -ne 0 ]; then
    echo "Error running make install "
    exit 2
  fi

  if [ ! -d $LLVM_SRC_HOME/build-debug ]; then
    mkdir $LLVM_SRC_HOME/build-debug
    cd $LLVM_SRC_HOME/build-debug
    cmake -G "Unix Makefiles" -D CMAKE_BUILD_TYPE=Debug \
              -DCMAKE_INSTALL_PREFIX=$LLVM_BIN_HOME/llvm-dbg  ../llvm \
              -DLLVM_ENABLE_SPHINX=true \
              -DSPHINX_OUTPUT_HTML=true
              # -DLLVM_ENABLE_DOXYGEN=true
              # -DCMAKE_C_COMPILER=$LLVM_SCRIPT_PATH/../faaltu/clang+llvm/bin/clang \
              # -DCMAKE_CXX_COMPILER=$LLVM_SCRIPT_PATH/../faaltu/clang+llvm/bin/clang++ 
    CMAKE_RET="$?"
    if [ $CMAKE_RET -ne 0 ]; then
      echo "Error running cmake command"
      echo "cmake return code : $CMAKE_RET"
      echo "removing $LLVM_SRC_HOME/build-release"
      rm -rf $LLVM_SRC_HOME/build-release
      exit 5
    fi
  fi
  SYSTEM_JOBS_ACCORDING_TO_MEMORY=$((SYSTEM_MEMORY / 8000000 ))
  SYSTEM_JOBS=$(($SYSTEM_JOBS_ACCORDING_TO_MEMORY>$SYSTEM_CORES?$SYSTEM_CORES:$SYSTEM_JOBS_ACCORDING_TO_MEMORY))
  for ((i=$SYSTEM_JOBS; i >= 1; i = i/2))
  do
    echo "Running with $i jobs"
    make -j $i
    MAKE_RET=$?
    if [ $MAKE_RET -eq 0 ]; then
      echo "make successful with $i jobs"
      break 
    fi
  done
  if [ $MAKE_RET -ne 0 ]; then
    echo "Error in running with 1 job"
    echo "Returning"
    exit 2
  fi
  make install
  MAKE_INSTALL_RET="$?"
  if [ $MAKE_INSTALL_RET -ne 0 ]; then
    echo "Error running make install "
    exit 2
  fi

  touch $LLVM_SCRIPT_PATH/../faaltu/llvm.done

fi
