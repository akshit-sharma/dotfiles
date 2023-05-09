# /bin/bash

NEED_BASH_REFRESH=0
NEED_ENTRY_REFRESH=0

DEBUG_SCRIPT=0

# function for returning the parent directory of this script
function parent_directory {
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    TARGET="$(readlink "$SOURCE")"
    if [[ $TARGET == /* ]]; then
      if [ $DEBUG_SCRIPT -ne 0]; then
        echo "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
      fi
      SOURCE="$TARGET"
    else
      DIR="$( dirname "$SOURCE" )"
      if [[ $DEBUG_SCRIPT -ne 0 ]]; then
        echo "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$DIR')"
      fi
      SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink,
                            # we need to resolve it relative to the path where the symlink file was located
    fi
  done
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "SOURCE is '$SOURCE'"
  fi
  RDIR="$( dirname "$SOURCE" )"
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  if [ "$DIR" != "$RDIR" ] && [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "DIR '$RDIR' resolves to '$DIR'"
  fi
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "DIR is '$DIR'"
  fi
  SCRIPT_PARENT_DIRECTORY=$DIR
}

# function for adding lines to ~/.bashrc if not present
# 1: LINE to change to if not present
# 2: Initial value of Refresh
# 3: Debug msg to print if present
# 4: CMD to achive desired LINE (only if updating LINE instead of adding LINE)
function update_bashrc {
  LINE=$1
  REFRESH=$2
  MSG_IF_PRESENT="${3:-3rd paramater to update_bashrc not given, no debug stmt}"
  CMD="${4:-$LINE}"

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "update_bashrc: LINE: $LINE"
    echo "update_bashrc: REFRESH: $REFRESH"
    echo "update_bashrc: MSG_IF_PRESENT: $MSG_IF_PRESENT"
    echo "update_bashrc: CMD: $CMD"
    echo "running: grep -qxe \"^${LINE}\$\" ~/.bashrc"
  fi
  if grep -qxe "^${LINE}$" ~/.bashrc;
  then
    if [[ $DEBUG_SCRIPT -ne 0 ]]; then
      echo "~/.bashrc $MSG_IF_PRESENT"
    fi
  else
    if [ "$LINE" = "$CMD" ]; then
      echo "" >> ~/.bashrc
      echo "$LINE" >> ~/.bashrc
    else
      if [[ $DEBUG_SCRIPT -ne 0 ]]; then
        echo "wanted to run: $CMD (but couldn't)"
      fi
    fi
    REFRESH=1
  fi
}

#1 command to run to get version
#2 version to statisfied
function version_statisfied {
  currentver=$(echo $1 | grep -oE '[[:digit:]]+\.[[:digit:]]+(.[[:digit:]]+)?')
  requiredver="${2}"
  if [ "$(printf '%s\n' "${requiredver}" "${currentver}" | sort -V | head -n1)" = "${requiredver}" ]; then
    return 0 # true
  else
    return 1 # false
  fi
}

if [ ! "$DOTFILES_SCRIPT_PARENT" ]; then
  parent_directory
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "Found parent directory as $SCRIPT_PARENT_DIRECTORY"
  fi
  SCRIPTPATH=$SCRIPT_PARENT_DIRECTORY
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "exporting DOTFILES_SCRIPT_PARENT=$SCRIPTPATH"
  fi
  export DOTFILES_SCRIPT_PARENT=$SCRIPTPATH
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "value of DOTFILES_SCRIPT_PARENT is ${DOTFILES_SCRIPT_PARENT}"
  fi
else
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "DOTFILES_SCRIPT_PARENT already set to $DOTFILES_SCRIPT_PARENT"
  fi
  SCRIPTPATH=$DOTFILES_SCRIPT_PARENT
fi

if [ -z "$1" ]; then
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "setting NEED_ENTRY_REFRESH to 1"
  fi
  NEED_ENTRY_REFRESH=1
else
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "setting NEED_ENTRY_REFRESH to 0"
  fi
  NEED_ENTRY_REFRESH=0
fi

function rm_dir_symlink {
  filename="$1"
  dir="${2:-}"
  file=$(basename ${filename})

  if [ -L $HOME/$dir/$file ]; then
    rm ${HOME}/${dir}/${file}
  fi
}

# function for creating symlink from dotfiles/$1 to $HOME/$2
function home_dir_symlink_rename {
  src_file="${SCRIPTPATH}/$1"
  dest_file="${HOME}/$2"

  # if symlink points to correct location, return
  if [ -L $dest_file ] && [ "$(readlink $dest_file)" = "$src_file" ]; then
    return
  fi

  # if file or folder exists, move to filename.old
  if [ -e $dest_file ]; then
    mv $dest_file $dest_file.old
  fi
  
  # if symlink exists, remove
  if [ -L $dest_file ]; then
    rm $dest_file
  fi

  if [[ $DEBUG_SCRIPT -ne 2 ]]; then
    echo "ln -s $src_file $dest_file"
  fi
  # create symlink
  ln -s $src_file $dest_file
}

# function for creating symlink to files in $HOME/$dir
function home_dir_symlink {
  filename="$1"
  dir="${2:-}"
  file=$(basename ${filename})

  if [ ! -f $HOME/$dir/$file ] && [ ! -d $HOME/$dir/$file ] && [ ! -L $HOME/$dir/$file ] \
    && [ ! -f $SCRIPTPATH/$filename ] && [ ! -d $SCRIPTPATH/$filename ] && [ ! -L $SCRIPTPATH/$filename ]; then
    echo "Could not determine if $HOME/$dir/$file or $SCRIPTPATH/$filename are file, directory or symlink"
    echo "return ............."
    return
  fi

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "symlink $HOME/$dir/$file ---> $SCRIPTPATH/$filename"
  fi
  if [ ! -d $HOME/$dir ]; then
    mkdir -p $HOME/$dir
  fi
  if [ ! -f $SCRIPTPATH/$filename ] && [ ! -d $SCRIPTPATH/$filename ]; then
                                                            # pretty much use less after getting files
    if [[ $DEBUG_SCRIPT -ne 0 ]]; then
      echo "copying $HOME/$dir/$file to $SCRIPTPATH/$filename"
    fi
    if [ -f $HOME/$dir/$file ]; then
      cp $HOME/$dir/$file $SCRIPTPATH/$filename   # usefull to add new files in the script
                                                      # instead of manually moving/copying
    elif [ -d $HOME/$dir/$file ]; then
      cp -r $HOME/$dir/$file $SCRIPTPATH/$filename
    else
      echo "don't know how to copy $HOME/$dir/$file to $SCRIPTPATH/$filename"
      echo "return ............."
      return
    fi
  fi
  if [ ! -f $SCRIPTPATH/$filename ] && [ ! -d $SCRIPTPATH/$filename ]; then
    echo "don't have source file or directory"
    echo "$SCRIPTPATH/$filename does not exit"
    echo "return ................"
    return
  fi
  if [ ! -L "$HOME/$dir/$file" ]; then
    if [ -d "$HOME/$dir/$file" ] || [ -f "$HOME/$dir/$file" ]; then
#  script_file_md5=`eval md5sum < $SCRIPTPATH/$filename | cut -d\  -f1`
#  destination_file_md5=`eval md5sum < $SCRIPTPATH/$filename | cut -d\  -f1`
      if [ ! -f "$HOME/$dir/$file.bk" ] && [ ! -d "$HOME/$dir/$file.bk" ] && [ ! -L "$HOME/$dir/$file.bk" ]; then
        if [[ $DEBUG_SCRIPT -ne 0 ]]; then
          echo "backing up $HOME/$dir/$file to $HOME/$dir/$file.bk"
        fi
        mv "$HOME/$dir/$file" "$HOME/$dir/$file.bk"
      else
        echo "$HOME/$dir/$file.bk already present skipping backup"
      fi
    fi
    if [ ! -L "$HOME/$dir/$file" ]; then
      if [ -f "$SCRIPTPATH/$filename" ] || [ -d "$SCRIPTPATH/$filename" ]; then
        if [[ $DEBUG_SCRIPT -ne 0 ]]; then
          echo "linking $SCRIPTPATH/$filename to $HOME/$dir/$file"
        fi
        ln -sT $SCRIPTPATH/$filename $HOME/$dir/$file
      else
        echo "Don't know how to link"
        echo "dir is $dir"
        echo "filename is $filename"
        echo "file is $file"
        exit 5
      fi
    fi
  fi
}

wget --version > /dev/null
WGET_RET="$?"

# function for download and extracting a file to desired directory
# DOWNLOAD_HOME (1st parameter) : parent directory required for extracting file (e.g. $HOME/faaltu)
# DOWNLOAD_DIR  (2nd parameter) : full directory with extraction (e.g. $HOME/faaltu/clang+llvm-6.0.1....)
# DOWNLOAD_FILE (3rd parameter) : file for downloading
# DOWNLOAD_URL  (4th parameter) : URL to download the tar file from
# DOWNLOAD_MD5  (5th parameter) : MD5 hash of DOWNLOAD_TAR, check if existing file was corrupted or incomplete
# DOWNLOAD_SIG_URL (6th parameter) : URL to download SIG file
function download_and_extract {
  DOWNLOAD_HOME="$1"
  DOWNLOAD_DIR="$2"
  DOWNLOAD_FILE="$3"
  DOWNLOAD_URL="$4"
  DOWNLOAD_MD5="$5"
  if [ -z "$5" ]; then
    VERIFY_MD5=false
  else
    if ! ${5}; then
      if [ -z "${6}" ]; then
        CLEAN_PREFIX=${DOWNLOAD_HOME}/${DOWNLOAD_FILE}
      else
        CLEAN_PREFIX=${DOWNLOAD_HOME}/${6}
      fi
      VERIFY_MD5=true
    else
      VERIFY_MD5=false
    fi
  fi

  SCRIPT_SUCC=0

  if [ $WGET_RET != 0 ]; then
    echo "Value of return from wget $WGET_RET"
    echo "Please make sure wget is installed"
    return
  fi

  if [[ $DOWNLOAD_DIR == $DOWNLOAD_HOME* ]]; then
    if ! ${VERIFY_MD5}; then
      echo "verifying MD5 disabled"
      if [ -f "$DOWNLOAD_HOME/$DOWNLOAD_FILE" ]; then
        rm -rf ${CLEAN_PREFIX}
      fi
    elif [ -f "$DOWNLOAD_HOME/$DOWNLOAD_FILE" ]; then
      EXISTING_MD5=`eval md5sum $DOWNLOAD_HOME/$DOWNLOAD_FILE | cut -d' ' -f1`
      if [ "$DOWNLOAD_MD5" != "$EXISTING_MD5" ]; then
        echo "will have to redownload $DOWNLOAD_FILE"
        echo "expected and existing md5 are $DOWNLOAD_MD5 and $EXISTING_MD5"
        echo "existing md5 - $DOWNLOAD_HOME/$DOWNLOAD_FILE"
        rm -rf ${CLEAN_PREFIX}
      else
        return
      fi
    fi
    if [ -d "$DOWNLOAD_DIR" ]; then
      rm -rf $DOWNLOAD_DIR
    fi
    if [ ! -d "$DOWNLOAD_HOME" ]; then
      mkdir -p $DOWNLOAD_HOME
    fi

    echo "downloading $DOWNLOAD_FILE to $DOWNLOAD_HOME"
    echo "wget $DOWNLOAD_URL -q -O $DOWNLOAD_HOME/$DOWNLOAD_FILE"
    wget $DOWNLOAD_URL -q -O $DOWNLOAD_HOME/$DOWNLOAD_FILE
    WGET_RETURN="$?"
    if [ $WGET_RETURN == "8" ]; then
      echo "Error from server side"
      echo "returning........"
      return
    fi
    if [ $WGET_RETURN -ne "0" ]; then
      echo "Download $DOWNLOAD_HOME/$DOWNLOAD_FILE not successful from $DOWNLOAD_URL"
    fi
    if [ ! -f ${DOWNLOAD_HOME}/${DOWNLOAD_FILE} ]; then
      echo "downloaded file from $DOWNLOAD_URL"
      echo "not found as ${DOWNLOAD_HOME}/${DOWNLOAD_FILE}"
      echo "returning........."
      return
    fi
    if [[ $DOWNLOAD_HOME/$DOWNLOAD_FILE == *.xz ]]; then
      echo "extracing (tar -xf $DOWNLOAD_HOME/$DOWNLOAD_FILE -C $DOWNLOAD_HOME)"
      tar -xf $DOWNLOAD_HOME/$DOWNLOAD_FILE -C $DOWNLOAD_HOME
      SCRIPT_SUCC=1
    elif [[ $DOWNLOAD_HOME/$DOWNLOAD_FILE == *.gz ]]; then
      echo "extracting (tar -zxf $DOWNLOAD_HOME/$DOWNLOAD_FILE -C $DOWNLOAD_HOME)"
      tar -zxf $DOWNLOAD_HOME/$DOWNLOAD_FILE -C $DOWNLOAD_HOME
      SCRIPT_SUCC=1
    elif [[ $DOWNLOAD_HOME/$DOWNLOAD_FILE == *bz2 ]]; then
      echo "extracting (tar -xjf $DOWNLOAD_HOME/$DOWNLOAD_FILE -C $DOWNLOAD_HOME)"
      tar -xjf $DOWNLOAD_HOME/$DOWNLOAD_FILE -C $DOWNLOAD_HOME
      SCRIPT_SUCC=1
    elif [[ $DOWNLOAD_FILE == *.sh ]]; then
      if [[ -x "$DOWNLOAD_HOME/$DOWNLOAD_FILE" ]]; then
        echo "file already executable"
      else
        chmod a+x $DOWNLOAD_HOME/$DOWNLOAD_FILE
        SCRIPT_SUCC=1
      fi
      return
    else
      echo "Don't know what to do with $DOWNLOAD_FILE"
    fi
  else
    echo "DOWNLOAD_HOME is $DOWNLOAD_HOME"
    echo "DOWNLOAD_DIR is $DOWNLOAD_DIR"
    echo "DOWNLOAD_DIR should start with same string as DOWNLOAD_HOME"
  fi
}

# install ncurses library if not available
function install_ncurses {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing/updating ncurses library"
  fi

  LIBNCURSES_MD5="98c889aaf8d23910d2b92d65be2e737a"
  LIBNCURSES_MAJOR_VER="6"
  LIBNCURSES_MINOR_VER="1"
  LIBNCURSES_DIR="ncurses-${LIBNCURSES_MAJOR_VER}.${LIBNCURSES_MINOR_VER}"
  LIBNCURSES_TAR="ncurses-${LIBNCURSES_MAJOR_VER}.${LIBNCURSES_MINOR_VER}.tar.gz"
  LIBNCURSES_URL="https://ftp.gnu.org/pub/gnu/ncurses/${LIBNCURSES_TAR}"
#https://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.9.tar.gz

  dpkg -l "libncurses${LIBNCURSES_MAJOR_VER}-dev" | grep '^ii'
  LIBNCURSES_DEV_INSTALLED="$?"

  # install libncurses
  if [ ${LIBNCURSES_DEV_INSTALLED} == "1" ] && [ ! -d ${SCRIPTPATH}/faaltu/${LIBNCURSES_DIR} ]; then
    download_and_extract ${SCRIPTPATH}/faaltu ${SCRIPTPATH}/faaltu/${LIBNCURSES_DIR} ${LIBNCURSES_TAR} ${LIBNCURSES_URL} ${LIBNCURSES_MD5}
    (cd ${SCRIPTPATH}/faaltu/${LIBNCURSES_DIR} && ./configure --prefix=${SCRIPTPATH}/faaltu/ncurses 2>&1> script_output.txt)
    PREBUILD_RET=$?
    if [ $PREBUILD_RET -ne 0 ]; then
      echo "error in running configure"
      echo "(cd ${SCRIPTPATH}/faaltu/${LIBNCURSES_DIR} && ./configure --prefix=${SCRIPTPATH}/faaltu/ncurses)"
      echo "returning......................"
      return
    fi
    make -C ${SCRIPTPATH}/faaltu/${LIBNCURSES_DIR} 2>&1> script_output.txt
    BUILD_RET=$?
    if [ $BUILD_RET -ne 0 ]; then
      echo "error in running make"
      echo "make -C ${SCRIPTPATH}/faaltu/${LIBNCURSES_DIR}"
      echo "returning......................"
      return
    fi
    make -C ${SCRIPTPATH}/faaltu/${LIBNCURSES_DIR} install 2>&1> script_output.txt
    INSTALL_RET=$?
    if [ $INSTALL_RET -ne 0 ]; then
      echo "error in running make install"
      echo "make -C ${SCRIPTPATH}/faaltu/${LIBNCURSES_DIR} install"
      echo "returning......................"
      return
    fi
  fi

}

function install_jq {
  if [ ! -d ${HOME}/.local/bin ]; then
    mkdir -p ${HOME}/.local/bin
  fi
  EXTRACT_DIR="${HOME}/.local/bin"
  JQ_VER="1.6"
  OS="linux"
  ARCH="64"
  JQ_DIR="jq-${JQ_VER}"
  JQ_FILE="jq-${OS}${ARCH}"
  JQ_URL="https://github.com/stedolan/jq/releases/download/${JQ_DIR}/${JQ_FILE}"
  download_and_extract ${SCRIPTPATH}/faaltu/${JQ_DIR} ${SCRIPTPATH}/faaltu/${JQ_DIR}/{JQ_FILE} ${JQ_FILE} ${JQ_URL}
  if [ ! -x ${SCRIPTPATH}/faaltu/${JQ_DIR}/${JQ_FILE} ]; then
    chmod +x ${SCRIPTPATH}/faaltu/${JQ_DIR}/${JQ_FILE}
  fi
  ln -sT ${SCRIPTPATH}/faaltu/${JQ_DIR}/${JQ_FILE} ${HOME}/.local/bin/jq
}

function install_compiledb {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing compiledb"
  fi
  which compiledb > /dev/null
  if [ "$?" == "0" ]; then
    return
  fi
  which pip3 > /dev/null
  pip3 install --user compiledb
}

# uninstall local vim
function uninstall_local_vim {
  if [ -d ${SCRIPTPATH}/faaltu/vim ]; then
    rm -rf ${SCRIPTPATH}/faaltu/vim*
  fi
  if [ -f ${HOME}/.local/bin/vim ]; then
    rm ${HOME}/.local/bin/ex
    rm ${HOME}/.local/bin/rview
    rm ${HOME}/.local/bin/rvim
    rm ${HOME}/.local/bin/view
    rm ${HOME}/.local/bin/vim
    rm ${HOME}/.local/bin/vimdiff
    rm ${HOME}/.local/bin/vimtutor
    rm ${HOME}/.local/bin/xxd
  fi
}

# install vim only if update is available
function install_vim {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing/updating vim"
  fi
  if false; then
    if [ -f $HOME/.local/bin/vim ]; then
      rm -rf $HOME/.local
    fi
  else
    if [ -d ${SCRIPTPATH}/faaltu/vim/.git ]; then
      rm -rf ${SCRIPTPATH}/faaltu/vim
    fi

    VIM_VER="8.1"
    VIM_DIR="vim${VIM_VER}"
    VIM_TAR="vim-${VIM_VER}.tar.bz2"
    VIM_URL="https://ftp.nluug.nl/pub/vim/unix/${VIM_TAR}"

    system_ver=$(vim --version | head -n1 | cut -d' ' -f5)

    if $(version_statisfied "$system_ver" "$VIM_VER"); then
      echo "vim ${system_ver} > ${VIM_VER}"
      echo "returning......................"
      return
    fi

    VIM_INSTALL="1"

    if [ ! -d ${SCRIPTPATH}/faaltu/vim/bin ]; then
      VIM_INSTALL="0"
    else
      VIM_CURRENT_VER=`eval ${SCRIPTPATH}/faaltu/vim/bin/vim --version | head -n1 | cut -d' ' -f5`
      if $(version_statisfied $(VIM_CURRENT_VER) "${VIM_INSTALL_VER}"); then
        VIM_INSTALL="0"
      else
        echo "vim up-to-date"
      fi
    fi

    if [ ${VIM_INSTALL} == 0 ]; then
      if [ -d ${SCRIPTPATH}/faaltu/vim ]; then
        rm -rf ${SCRIPTPATH}/faaltu/vim/*
      fi
      download_and_extract ${SCRIPTPATH}/faaltu ${SCRIPTPATH}/faaltu/${VIM_DIR} ${VIM_TAR} ${VIM_URL} ${VIM_MD5}
      install_ncurses
      (cd ${SCRIPTPATH}/faaltu/${VIM_DIR} && ./configure --enable-python3interp --with-features=huge --enable-gui=auto --prefix=${SCRIPTPATH}/faaltu/vim)
      PREBUILD_RET=$?
      if [ $PREBUILD_RET -ne 0 ]; then
        echo "error in running configure"
        echo "(cd ${SCRIPTPATH}/faaltu/${VIM_DIR} && ./configure --enable-python3interp --with-features=huge --enable-gui=auto --prefix=${SCRIPTPATH}/faaltu/vim )"
        echo "returning......................"
        return
      fi
      make -C ${SCRIPTPATH}/faaltu/${VIM_DIR} -j 8  2>&1> script_output.txt
      BUILD_RET=$?
      if [ $BUILD_RET -ne 0 ]; then
        echo "error in running make"
        echo "make -C ${SCRIPTPATH}/faaltu/${VIM_DIR} -j 8"
        echo "returning......................"
        return
      fi
      make -C ${SCRIPTPATH}/faaltu/${VIM_DIR} install 2>&1> script_output.txt
      INSTALL_RET=$?
      if [ $INSTALL_RET -ne 0 ]; then
        echo "error in running make install"
        echo "make -C ${SCRIPTPATH}/faaltu/${VIM_DIR} install"
        echo "returning......................"
        return
      fi
    fi
  fi
}

# install ctags only if not installed or MD5 changed
function install_ctags {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing ctags"
  fi
  if [ $WGET_RET == 0 ]; then
    CTAGS_CORRECT_MD5="c00f82ecdcc357434731913e5b48630d"
    CTAGS_VER="5.9"
    CTAGS_MINOR_VER="20221106.0"
    CTAGS_DIR="ctags-p${CTAGS_VER}.${CTAGS_MINOR_VER}"
    CTAGS_TAR="p${CTAGS_VER}.${CTAGS_MINOR_VER}.tar.gz"
    CTAGS_URL="https://github.com/universal-ctags/ctags/archive/refs/tags/${CTAGS_TAR}"
    CTAGS_INSTALL="0"

    which ctags > /dev/null
    system_ver=" "
    if [ "$?" == "0" ]; then
      system_ver=$(ctags --version | head -n1 | cut -d' ' -f3)
    fi

    if $(version_statisfied "$system_ver" "$CTAGS_VER"); then
      if [[ $DEBUG_SCRIPT -ne 0 ]]; then
        echo "ctags ${system_ver} > ${CTAGS_VER}"
        echo "returning......................"
      fi
      return
    fi

    if [ -f ${HOME}/bin/ctags ]; then
      local_ver=$($HOME/bin/ctags --version | head -n1 | cut -d' ' -f3)
      if $(version_statisfied "$local_ver" "$CTAGS_VER"); then
        if [[ $DEBUG_SCRIPT -ne 0 ]]; then
          echo "ctags ${system_ver} > ${CTAGS_VER}"
          echo "returning......................"
        fi
        return
      fi
    fi

    if [ ! -f "$SCRIPTPATH/faaltu/$CTAGS_TAR" ]; then
      download_and_extract $SCRIPTPATH/faaltu/ $SCRIPTPATH/faaltu/$CTAGS_DIR $CTAGS_TAR $CTAGS_URL $CTAGS_MD5
      CTAGS_INSTALL=1
    elif [ ! -f $HOME/bin/ctags ]; then
      CTAGS_INSTALL=1
    fi
    if [[ $CTAGS_INSTALL == 1 ]]; then
      if [ -f "$SCRIPTPATH/faaltu/$CTAGS_DIR/autogen.sh" ]; then
        (cd $SCRIPTPATH/faaltu/$CTAGS_DIR && ./autogen.sh)
        (cd $SCRIPTPATH/faaltu/$CTAGS_DIR && ./configure --prefix=$HOME)
        make -C $SCRIPTPATH/faaltu/$CTAGS_DIR 2>&1> script_output.txt
        make -C $SCRIPTPATH/faaltu/$CTAGS_DIR install 2>&1> script_output.txt
      else
        echo "$SCRIPTPATH/faaltu/$CTAGS_DIR/configure not found"
      fi
    fi
  fi
}

function uninstall_clang_llvm {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "uninstalling clang+llvm"
  fi

  if [ -d $HOME/clang+llvm* ]; then
    rm -rf $HOME/clang+llvm*
  fi

}

# install clang+llvm only if not installed or MD5 changed
function install_clang_llvm {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing clang+llvm"
  fi
  if [ $WGET_RET -ne 0 ]; then
    echo "wget not found, cannot download LLVM Pre Binary"
    exit 1
  fi

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "wget found"
  fi
  LLVM_PREBINARY_VER="15.0.3"
  OS_RELEASE_VER=`lsb_release -rs`
  if [ ${OS_RELEASE_VER} = "18.04" ]; then
    OS_RELEASE_VER="16.04"
  fi
  LLVM_PREBINARY_DIR="clang+llvm-${LLVM_PREBINARY_VER}-x86_64-linux-gnu-ubuntu-${OS_RELEASE_VER}"
  LLVM_PREBINARY_TAR="${LLVM_PREBINARY_DIR}.tar.xz"
  LLVM_PREBINARY_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_PREBINARY_VER}/${LLVM_PREBINARY_TAR}"
  LLVM_CLEAN_PREFIX="clang+llvm-*"
  LLVM_INSTALL=false

  LLVM_PREBINARY_DIR="clang+llvm-${LLVM_PREBINARY_VER}-aarch64-linux-gnu"
  LLVM_PREBINARY_TAR="${LLVM_PREBINARY_DIR}.tar.xz"
  LLVM_PREBINARY_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_PREBINARY_VER}/${LLVM_PREBINARY_TAR}"
  LLVM_CLEAN_PREFIX="clang+llvm-*"
  LLVM_INSTALL=false

  CLANG_HOME=/usr
  cmd="${CLANG_HOME}/bin/clang -dumpversion"
  currentver=""

  if [ -L "${CLANG_HOME}/bin/clang" ] || [ -f "${CLANG_HOME}/bin/clang" ]; then
    currentver=`$cmd`
  fi

  if $(version_statisfied "$currentver" "$LLVM_PREBINARY_VER"); then
    if [[ $DEBUG_SCRIPT -ne 0 ]]; then
      echo "local install clang $currentver > $LLVM_PREBINARY_VER at $CLANG_HOME"
      echo "returning....."
    fi
    return
  fi


  CLANG_HOME=${SCRIPTPATH}/faaltu/clang+llvm

  if [ ! -L "${CLANG_HOME}" ]; then
    LLVM_INSTALL=true
  else
    cmd="${CLANG_HOME}/bin/clang -dumpversion"
    if [ -L "${CLANG_HOME}/bin/clang" ] || [ -f "${CLANG_HOME}/bin/clang" ]; then
      currentver=$($cmd)
      if $(version_statisfied "$currentver" "$LLVM_PREBINARY_VER"); then
        if [[ $DEBUG_SCRIPT -ne 0 ]]; then
          echo "local install clang $currentver > $LLVM_PREBINARY_VER at ${CLANG_HOME}"
          echo "returning....."
        fi
        return
      fi
    fi
    LLVM_INSTALL=true
  fi

  if [ $LLVM_INSTALL = true ]; then
    download_and_extract $SCRIPTPATH/faaltu $SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR $LLVM_PREBINARY_TAR $LLVM_PREBINARY_URL false ${LLVM_CLEAN_PREFIX}
  fi
  if [ ! -L $SCRIPTPATH/faaltu/clang+llvm ]; then
    ln -sT $SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR $SCRIPTPATH/faaltu/clang+llvm
  else
    LLVM_CURRENT_LINK=`eval readlink -f $SCRIPTPATH/faaltu/clang+llvm`
    if [ "$LLVM_CURRENT_LINK" != "$SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR" ]; then
      rm $SCRIPTPATH/faaltu/clang+llvm
      ln -sT $SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR $SCRIPTPATH/faaltu/clang+llvm
    fi
  fi

}

# install git large file system (git lfs) if not installed or version updated
function install_gitlfs {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing git lfs"
  fi
  GIT_LFS_MD5="a8363aba7fa60e1769571c4f49affbcb"
  GIT_LFS_VER="2.5.1"
  GIT_LFS_DIR="git-lfs"
  GIT_LFS_TAR="git-lfs-linux-amd64-v${GIT_LFS_VER}.tar.gz"
  GIT_LFS_URL="https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VER}/${GIT_LFS_TAR}"
  GIT_LFS_INSTALL="1"

  if [ $WGET_RET == 0 ]; then
    git lfs --version > /dev/null
    if [ "$?" != 0 ]; then
      if [[ $DEBUG_SCRIPT -ne 0 ]]; then
        echo "git lfs not found"
      fi
      # download and install lfs
      GIT_LFS_INSTALL="0"
    else
      if [[ $DEBUG_SCRIPT -ne 0 ]]; then
        echo "git lfs found"
      fi
      INSTALLED_VER=`eval git lfs --version | cut -d' ' -f1 | cut -d'/' -f2`
      if [ "$GIT_LFS_VER" != "$INSTALLED_VER" ]; then
        # version different need removal, download and install
        GIT_LFS_INSTALL="0"
      fi
    fi
  else
    echo "wget not found, cannot download git lfs"
    return
  fi

  if [ $GIT_LFS_INSTALL == 0 ]; then
    if [[ $DEBUG_SCRIPT -ne 0 ]]; then
      echo "instal git lfs set to true"
    fi
    if [ -f $SCRIPTPATH/faaltu/$GIT_LFS_TAR ]; then
      rm $SCRIPTPATH/faaltu/$GIT_LFS_TAR
    fi
    if [ ! -d $SCRIPTPATH/faaltu/$GIT_LFS_DIR ]; then
      mkdir -p $SCRIPTPATH/faaltu/$GIT_LFS_TAR
    fi
    download_and_extract $SCRIPTPATH/faaltu/$GIT_LFS_DIR $SCRIPTPATH/faaltu/$GIT_LFS_DIR $GIT_LFS_TAR $GIT_LFS_URL $GIT_LFS_MD5
    if [ -f $SCRIPTPATH/faaltu/$GIT_LFS_DIR/install.sh ]; then
      PREFIX=$HOME $SCRIPTPATH/faaltu/$GIT_LFS_DIR/install.sh
      git -C $SCRIPTPATH lfs install
    else
      echo "$SCRIPTPATH/faaltu/$GIT_LFS_DIR/install.sh not found"
      echo "git lfs install unsuccessful"
    fi
  fi
}

# install i3wmIPC only if
function install_i3wmIPC {
  i3 --version 2>&1> script_output.txt
  I3_RET="$?"
  if [[ I3_RET -eq 127 ]]; then # i3 not installed
    echo "i3 not installed, returning..."
    return
  fi
  if [[ I3_RET -ne 0 ]]; then
    echo "i3 --version returned ${I3_RET}"
    return
  fi
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "building i3wmIPC"
  fi

  I3WMIPC_DIR=$HOME/.config/i3/i3wmIPC

  make --version > /dev/null
  MAKE_RET=$?
  cmake --version > /dev/null
  CMAKE_RET=$?
  if [ $MAKE_RET -eq 0 ] && [ $CMAKE_RET -eq 0 ]; then
    if [ ! -d $I3WMIPC_DIR ]; then
      git clone https://github.com/akshit-sharma/i3wmIPC.git $I3WMIPC_DIR
    fi
    if [ -d $I3WMIPC_DIR ]; then
      I3WMIPC_HASH=$(git -C $I3WMIPC_DIR rev-parse @)
      if [ ! -f $SCRIPTPATH/faaltu/.i3wm_ipc.hash ]; then
        I3WMIPC_OLD_HASH="Nothing"
      else
        I3WMIPC_OLD_HASH=$(cat $SCRIPTPATH/faaltu/.i3wm_ipc.hash)
      fi
      if [ "$I3WMIPC_HASH" != "$I3WMIPC_OLD_HASH" ]; then
        if [ ! -d ${I3WMIPC_DIR}/build ]; then
          mkdir ${I3WMIPC_DIR}/build
        fi
        (${I3WMIPC_DIR}/download_prerequisites.sh)
        (cd ${I3WMIPC_DIR} && cmake -G"Unix Makefiles" -B${I3WMIPC_DIR}/build  -H${I3WMIPC_DIR})
        PREBUILD_RET="$?"
        if [ $PREBUILD_RET -ne 0 ]; then
          echo "error in running cmake"
          echo "cmake -G\"Unix Makefiles\" -B${I3WMIPC_DIR}/build  -H${I3WMIPC_DIR}"
          echo "returning........................"
          return
        fi

        make -C${I3WMIPC_DIR}/build
        BUILD_RET="$?"
        if [ $BUILD_RET -ne 0 ]; then
          echo "error in running make"
          echo "make -C${I3WMIPC_DIR}/build"
          echo "returning......................."
          return
        fi

        echo $I3WMIPC_HASH > $SCRIPTPATH/faaltu/.i3wm_ipc.hash

      else
        echo "i3wmIPC is latest"
      fi
    else
      echo "This should not happen !!!"
      echo "Cloning https://github.com/akshit-sharma/i3wmIPC.git did not create $I3WMIPC_DIR"
      echo "Returning...."
      return
    fi
  fi

}

# install cmake
function install_cmake {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing cmake"
  fi
  CMAKE_VER="3.21"
  CMAKE_SUB_VER="4"
  CMAKE_DIR="cmake"
  CMAKE_SCRIPT="cmake-${CMAKE_VER}.${CMAKE_SUB_VER}-linux-x86_64.sh"
  CMAKE_URL="https://cmake.org/files/v${CMAKE_VER}/${CMAKE_SCRIPT}"

  CMAKE_INSTALL_DIR="$HOME/Softwares/cmake/"
  CMAKE_CMD="--skip-license --exclude-subdir --prefix=${CMAKE_INSTALL_DIR}"

  system_ver=$(cmake --version | head -n 1 | cut -d' ' -f3)

  if $(version_statisfied "$system_ver" "$CMAKE_VER.$CMAKE_SUB_VER"); then
    if [[ $DEBUG_SCRIPT -ne 0 ]]; then
      echo "cmake $system_ver > $CMAKE_VER.$CMAKE_SUB_VER"
      echo "returning..."
    fi
    return
  fi

  if [ ! -d $CMAKE_INSTALL_DIR ]; then
    mkdir -p $CMAKE_INSTALL_DIR
  fi

  download_and_extract $SCRIPTPATH/faaltu/$CMAKE_DIR $SCRIPTPATH/faaltu/$CMAKE_DIR \
    $CMAKE_SCRIPT $CMAKE_URL false

  if [ $SCRIPT_SUCC -eq 1 ]; then
    $SCRIPTPATH/faaltu/$CMAKE_DIR/$CMAKE_SCRIPT $CMAKE_CMD
  fi

}

# install Homebrew
function install_brew {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing HomeBrew"
  fi

  BREW_VER="3.3.3"

  which brew > /dev/null
  if [ "$?" == 0 ]; then
    system_ver=$(brew --version | head -n1 | cut -d' ' -f2)
    system_path=$(realpath brew)
    if $(version_statisfied "$system_ver" "$BREW_VER"); then
      if [[ $DEBUG_SCRIPT -ne 0 ]]; then
        echo "brew $system_ver > $BREW_VER"
        echo "returning..."
      fi
      return
    fi
  fi

  if [ ! -d ${SCRIPTPATH}/faaltu/homebrew ]; then
    if [ -d $HOME/.linuxbrew ]; then
      rm -rf $HOME/.linuxbrew
    fi
  fi

  if [ -d ${SCRIPTPATH}/faaltu/homebrew/brew ]; then
    rm -rf ${SCRIPTPATH}/faaltu/homebrew
  fi

  if [ ! -d ${SCRIPTPATH}/faaltu/homebrew ]; then
    git clone https://github.com/Homebrew/brew ${SCRIPTPATH}/faaltu/homebrew
  fi

  BREW_EXTRACT_DIR=${SCRIPTPATH}/faaltu/homebrew
  BREW_LINK=${SCRIPTPATH}/faaltu/brew

  currentver="0.0.0"
  if [ -d $HOME/.linuxbew/bin ]; then
    currentver=$($HOME/.linuxbrew/bin/brew --version | head -n1 | cut -d' ' -f2)
  fi

  if [ ! -f ${BREW_LINK} ]; then
    echo "${BREW_LINK} not found"
  elif $(version_statisfied "$currentver" "$BREW_VER"); then
    echo "homebrew version statisfied"
    echo "returning......"
    return
  else
    rm ${BREW_LINK}
  fi

  git checkout tags/${BREW_VER} -b v${BREW_VER}

  if [ ! -L ${BREW_LINK} ]; then
    ln -sT ${BREW_EXTRACT_DIR} ${BREW_LINK}
  fi

  if [ ! -L ${HOME}/.linuxbrew ]; then
    ln -sT ${BREW_LINK} ${HOME}/.linuxbrew
  fi

}

function install_node {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing node"
  fi
  system_ver=$(node --version)
  NODE_VERSION="16.15.1"
  if (version_statisfied "$system_ver" "$NODE_VERSION"); then
    if [[ $DEBUG_SCRIPT -ne 0 ]]; then
      echo "system node version $system_ver > $NODE_VERSION statisfied"
      echo "returning......"
    fi
    return
  fi
  if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    local_ver=$(node --version)
    if (version_statisfied "$local_ver" "$NODE_VERSION"); then
      if [[ $DEBUG_SCRIPT -ne 0 ]]; then
        echo "local node version $local_ver > $NODE_VERSION statisfied"
        echo "returning......"
      fi
      return
    fi
  fi
  if [ ! -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm" && (
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    cd "$NVM_DIR"
    git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
  ) && \. "$NVM_DIR/nvm.sh"
  fi
  nvm install ${NODE_VERSION}

}

function install_github_neovim {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing neovim"
  fi
  system_ver=$(nvim --version | head -n1 | cut -d' ' -f2)
  NEOVIM_VERSION="0.9.0"
  if (version_statisfied "$system_ver" "$NEOVIM_VERSION"); then
    if [[ $DEBUG_SCRIPT -ne 0 ]]; then
      echo "system neovim version $system_ver > $NEOVIM_VERSION statisfied"
      echo "returning......"
    fi
    return
  fi
  if [ -f "$HOME/Softwares/nvim-linux64/bin/nvim" ]; then
    local_ver=$($HOME/Softwares/nvim/bin/nvim --version | head -n1 | cut -d' ' -f2)
    if (version_statisfied "$local_ver" "$NEOVIM_VERSION"); then
      if [[ $DEBUG_SCRIPT -ne 0 ]]; then
        echo "local neovim version $local_ver > $NEOVIM_VERSION statisfied"
        echo "returning......"
      fi
      return
    fi
  fi

  DOWNLOAD_DIR=$DOTFILES_SCRIPT_PARENT/faaltu/
  DOWNLOAD_FILE="nvim-linux64.tar.gz"
  DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux64.tar.gz"

  if [ -d "$HOME/Softwares/nvim-linux64" ]; then
    rm -rf $HOME/Softwares/nvim-linux64
  fi

  download_and_extract $DOWNLOAD_DIR/neovimTar $DOWNLOAD_DIR/neovimTar $DOWNLOAD_FILE $DOWNLOAD_URL false
  mv $DOWNLOAD_DIR/nvim-linux64 $HOME/Softwares/

}


function uninstall_brew_neovim {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "removing neovim from brew"
  fi
  if [ ! -f ~/.linuxbrew/bin/nvim ]; then
    return
  fi
  brew uninstall neovim
}

function install_act {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing act"
  fi
  which act
  if [ "$?" == 0 ]; then
    return
  fi
  brew install nektos/tap/act
}

function install_cppcheck {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing cppcheck"
  fi
  which cppcheck
  if [ "$?" == 0 ]; then
    return
  fi
  brew install cppcheck
}

function install_gperftools {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing gperftools"
  fi
  which pprof > /dev/null
  if [ "$?" == 0 ]; then
    return
  fi
  brew install gperftools
}

function install_ycm {
# install YouCompleteMe only if not installed or if YCM is updated
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing YouCompleteMe"
  fi
  make --version > /dev/null
  MAKE_RET=$?
  cmake --version > /dev/null
  CMAKE_RET=$?
  if [ $MAKE_RET -eq 0 ] && [ $CMAKE_RET -eq 0 ]; then
    if [ -f $HOME/.vim/bundle/YouCompleteMe/install.py ]; then
      YCM_HASH=$(git -C $HOME/.vim/bundle/YouCompleteMe/ rev-parse @)
      if [ ! -f $SCRIPTPATH/faaltu/ycm.hash ]; then
        YCM_OLD_HASH="Nothing"
      else
        YCM_OLD_HASH=$(cat $SCRIPTPATH/faaltu/ycm.hash)
      fi
      if [ "$YCM_HASH" != "$YCM_OLD_HASH" ]; then
        CC=${SCRIPTPATH}/faaltu/clang+llvm/bin/clang CXX=${SCRIPTPATH}/faaltu/clang+llvm/bin/clang++ python3 $HOME/.vim/bundle/YouCompleteMe/install.py --clang-completer --clangd-completer --cmake-path ${HOME}/Softwares/cmake/bin/cmake
        if [ "$?" != "0" ]; then
          echo "error running"
          echo "python3 $HOME/.vim/bundle/YouCompleteMe/install.py --clang-completer --clangd-completer"
          echo "returning......"
          return
        fi
        echo $YCM_HASH > $SCRIPTPATH/faaltu/ycm.hash
        if [[ $DEBUG_SCRIPT -ne 0 ]]; then
          echo "Installed/Updated YouCompleteMe"
        fi
      else
        if [[ $DEBUG_SCRIPT -ne 0 ]]; then
          echo "YouCompleteMe is latest"
        fi
      fi
    fi
  fi
}

function install_vcpkg {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing vcpkg"
  fi
  which vcpkg > /dev/null
  if [ "$?" == 0 ]; then
    return
  fi
  if [ ! -d $HOME/Softwares ]; then
    mkdir -p $HOME/Softwares
  fi
  if [ -d $HOME/Softwares ] && [ ! -d $HOME/Softwares/vcpkg ]; then
    git clone https://github.com/Microsoft/vcpkg.git $HOME/Softwares/vcpkg
  fi
  if [ -d $HOME/Softwares/vcpkg ]; then
    (cd $HOME/Softwares/vcpkg && ./bootstrap-vcpkg.sh)
  fi
}

function install_conan {

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing conan"
  fi
  which conan > /dev/null
  if [ "$?" == "0" ]; then
    return
  fi
  which pip3 > /dev/null
  pip3 install --user conan > /dev/null

}

function install_cmake_language_server {

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing cmake-language-server"
  fi
  which cmake-language-server > /dev/null
  if [ "$?" == "0" ]; then
    return
  fi
  which pip3 > /dev/null
  pip3 install --user cmake-language-server

}

function install_bash_language_server {

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing bash-language-server"
  fi
  which bash-language-server
  if [ "$?" == "0" ]; then
    return
  fi
  which npm
  npm i -g bash-language-server

}

function install_digestif_language_server { # for latex

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing digestif"
  fi
  which digestif
  if [ "$?" == "0" ]; then
    return
  fi
  which luarocks
  luarocks install digestif

}

function install_python_language_server {

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing python-language-server"
  fi
  which cmake-language-server
  if [ "$?" == "0" ]; then
    return
  fi
  which pip3
  pip3 install --user 'python-language-server[all]'

}

function install_doxygen {

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing doxygen"
  fi
  which cmake > /dev/null
  which make > /dev/null

  DOXYGEN_CORRECT_MD5="7997a15c73a8bd6d003eaba5c2ee2b47"
  DOXYGEN_VER="1.9.2"
  DOXYGEN_GITHUB_VER="1_9_2"
  DOXYGEN_SRC_DIR="doxygen"
  DOXYGEN_BUILD_DIR="${DOXYGEN_SRC_DIR}/build"

  DOXYGEN_INSTALL_DIR="$HOME/.local"
  DOXYGEN_CMAKE_CMD="-B${SCRIPTPATH}/faaltu/${DOXYGEN_BUILD_DIR} -H${SCRIPTPATH}/faaltu/${DOXYGEN_SRC_DIR} -DCMAKE_INSTALL_PREFIX=${DOXYGEN_INSTALL_DIR}"

  which doxygen > /dev/null
  if [ "$?" == "0" ]; then
    system_ver=$(doxygen --version | cut -d' ' -f1)

    if $(version_statisfied "${system_ver}" "${DOXYGEN_VER}"); then
      echo "doxygen ${system_ver} > ${DOXYGEN_VER}"
      return
    fi
  fi

  if [ ! -d ${SCRIPTPATH}/faaltu/${DOXYGEN_SRC_DIR} ]; then
    git clone https://github.com/doxygen/doxygen ${SCRIPTPATH}/faaltu/${DOXYGEN_SRC_DIR}
  fi

  branch_name=$(git -C ${SCRIPTPATH}/faaltu/${DOXYGEN_SRC_DIR} rev-parse --abbrev-ref HEAD)
  if $(version_statisfied "$branch_name" "$DOXYGEN_VER"); then
    git -C ${SCRIPTPATH}/faaltu/${DOXYGEN_SRC_DIR} checkout tags/Release_${DOXYGEN_GITHUB_VER} -b v${DOXYGEN_VER}

    cmake ${DOXYGEN_CMAKE_CMD}
    make -C${SCRIPTPATH}/faaltu/${DOXYGEN_BUILD_DIR} -j 8

    BUILD_RET="$?"
    if [ $BUILD_RET -ne 0 ]; then
      echo "error in running make"
      echo "make -C${DOXYGEN_BUILD_DIR}"
      echo "returning......................."
      return
    fi

    make -C${SCRIPTPATH}/faaltu/${DOXYGEN_BUILD_DIR} install

  fi

}

function install_breathe_and_sphnix {

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing breathe and sphinx"
  fi
  which sphinx-build > /dev/null
  if [ "$?" == "0" ]; then
    return
  fi
  which pip3 > /dev/null
  pip3 install --user breathe
  pip3 install --user sphinx

}

function install_valgrind {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing valgrind"
  fi

  if [ $WGET_RET == 0 ]; then
    echo "wget found"

    VALGRIND_MD5="46e5fbdcbc3502a5976a317a0860a975"
    VALGRIND_VER="3.15"
    VALGRIND_SUB_VER="0"
    VALGRIND_DIR="valgrind-${VALGRIND_VER}.${VALGRIND_SUB_VER}"
    VALGRIND_TAR="valgrind-${VALGRIND_VER}.${VALGRIND_SUB_VER}.tar.bz2"
    VALGRIND_URL="https://sourceware.org/pub/valgrind/${VALGRIND_TAR}"

    VALGRIND_INSTALL_DIR="${SCRIPTPATH}/faaltu/${VALGRIND_DIR}"

    VALGRIND_INSTALL="1"

    if [ ! -d ${VALGRIND_INSTALL_DIR} ]; then
      mkdir -p ${VALGRIND_INSTALL_DIR}
    fi

    if [ -d ${SCRIPTPATH}/faaltu/valgrind/bin ]; then
      VALGRIND_INSTALL_VER=`eval ${SCRIPTPATH}/faaltu/valgrind/bin/valgrind --version | head -n1 | cut -d'-' -f2`
      if [ "${VALGRIND_INSTALL_VER}" != "${VALGRIND_VER}.${VALGRIND_SUB_VER}" ]; then
        VALGRIND_INSTALL="0"
      else
        echo "valgrind up-to-date"
      fi
    else
        VALGRIND_INSTALL="0"
    fi

    if [ ${VALGRIND_INSTALL} == 0 ]; then
      if [ -d ${SCRIPTPATH}/faaltu/valgrind ]; then
        rm -rf ${SCRIPTPATH}/faaltu/valgrind/*
      fi
      download_and_extract $SCRIPTPATH/faaltu ${SCRIPTPATH}/faaltu/${VALGRIND_DIR} ${VALGRIND_TAR} ${VALGRIND_URL} ${VALGRIND_MD5}
      (cd ${SCRIPTPATH}/faaltu/${VALGRIND_DIR} && ./configure --prefix=${SCRIPTPATH}/faaltu/valgrind/)
      make -C ${SCRIPTPATH}/faaltu/${VALGRIND_DIR} 2>&1> script_output.txt
      make -C ${SCRIPTPATH}/faaltu/${VALGRIND_DIR} install 2>&1> script_output.txt
    fi
    if [ ! -L ${HOME}/Softwares/valgrind ]; then
      ln -sT $SCRIPTPATH/faaltu/valgrind ${HOME}/Softwares/valgrind
    else
      VALGRIND_CURRENT_LINK=`eval readlink -f ${HOME}/Softwares/valgrind`
      if [ "$VALGRIND_CURRENT_LINK" != "${SCRIPTPATH}/faaltu/valgrind" ]; then
        rm ${HOME}/Softwares/valgrind
        ln -sT ${SCRIPTPATH}/faaltu/valgrind ${HOME}/Softwares/valgrind
      fi
    fi
  else
    echo "wget not found, cannot download LLVM Pre Binary"
  fi

}

install_brew # home_dir_symlink for linuxbrew depends on this

rm_dir_symlink llvm_scripts
rm_dir_symlink gcc_scripts

# script for adding llvm to environment
# home_dir_symlink llvm_scripts .
# script for adding gcc to environment
# home_dir_symlink gcc_scripts .

if [ -d ~/.vim/syntax ]; then
  rm -rf ~/.vim/syntax
fi

# manual linking of dir inside ~/.vim
home_dir_symlink_rename vim .vim

# symlink directory for vimwiki
home_dir_symlink vimwiki .

# symlink i3 config
home_dir_symlink i3 .config
home_dir_symlink i3status .config

#home_dir_symlink .gdbinit .

home_dir_symlink .set_screen.sh .
home_dir_symlink .set_wallpaper.sh .

home_dir_symlink faaltu/homebrew/.linuxbrew .

home_dir_symlink cpp_project/new_cpp_project.sh .local/bin

if [ -L ~/.toggletouchpad.sh ]; then
  rm  ~/.toggletouchpad.sh
fi

if [ -L ~/.noctrlq.sh ]; then
  rm  ~/.noctrlq.sh
fi

# # symlink toggletouchpad.sh
# home_dir_symlink .toggletouchpad.sh .
# # disable ctrlq for firefox
# home_dir_symlink .noctrlq.sh .

# if kde plasma get my shortcuts
if [[ $DESKTOP_SESSION = *"plasma" ]]; then
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
     echo "plasma (kde) detected"
  fi
  PLASMASHELL_VERSION=`eval plasmashell --version | sed -nr 's/plasmashell ([0-9][0-9]*\.*)/\1/p'`
  PLASMASHELL_MAJOR=`plasmashell --version | sed -rn 's/plasmashell ([0-9])\.[0-9].*/\1/p'`
  if [ $PLASMASHELL_MAJOR -eq 5 ]; then
    home_dir_symlink kglobalshortcutsrc.kksrc .config
    home_dir_symlink khotkeysrc .config
    home_dir_symlink quicktile.cfg .config
    home_dir_symlink Xmodmap .config
  else
    echo "Don't know how to handle this plasma version"
    echo "PLASMASHELL_VERSION $PLASMASHELL_VERSION"
    echo "PLASMASHELL_MAJOR $PLASMASHELL_MAJOR"
    OUTPUT_PLASMASHELL=`eval plasmashell --version`
    echo "plasmashell --version is $OUTPUT_PLASMASHELL"
  fi
else
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "desktop session not plasma ($DESKTOP_SESSION)"
  fi
fi

if [ ! -d $HOME/.config ]; then
  mkdir $HOME/.config
fi

if [ -f $HOME/.nvim ]; then
  rm $HOME/.nvim
fi

if [ -L $HOME/.vimrc ]; then
  rm $HOME/.vimrc
fi

home_dir_symlink nvim .config
home_dir_symlink yapf .config
home_dir_symlink .flake8 .
home_dir_symlink .pylintrc .
home_dir_symlink .my_ssh_agent .
home_dir_symlink .my_profile .
home_dir_symlink .my_bashrc .
home_dir_symlink .inputrc .
home_dir_symlink .my_entry .
home_dir_symlink .tmux.conf .
home_dir_symlink .latexmkrc .
home_dir_symlink .mydircolors .
home_dir_symlink .condarc .
home_dir_symlink .actrc .

if [ ! -f "$HOME/.my_vars" ]; then
  touch $HOME/.my_vars
fi


mkdir -p $HOME/.vim/tags
mkdir -p $HOME/.local/bin

# setup virtualenv for python2 and python3
function python_virtualenv_setup {
  VERSION_NUMBER="$1"
  VIRTUALENV_EXEC="virtualenv"

  if [ -d "$HOME/venv" ]; then
    if [ "$VERSION_NUMBER" == "3" ]; then
      if [[ $DEBUG_SCRIPT -ne 0 ]]; then
        echo "virtualenv for python3 exists ($HOME/venv)"
      fi
      return
    fi
  fi

  if [ -d "$HOME/venv2" ]; then
    if [ "$VERSION_NUMBER" == "2" ]; then
      if [[ $DEBUG_SCRIPT -ne 0 ]]; then
        echo "virtualenv for python2 exists ($HOME/venv2)"
      fi
      return
    fi
  fi

  which $VIRTUALENV_EXEC > /dev/null
  if [ "$?" != "0" ]; then
    #virtualenv not in path
    if [ ! -f $HOME/.local/bin/virtualenv ]; then
      # /usr/bin/python3
      if [ ! -f /usr/bin/python3 ] && [ ! -L /usr/bin/python3 ]; then
        echo "From python_virtualenv_setup: Cannot find /usr/bin/python3"
        echo "Cannot create virtualenv"
        return
      else
        WHICH_PIP3=`which pip3`
        if [ "$?" != "0" ] || [ "$WHICH_PIP3" == "$HOME/.local/bin/pip3" ]; then
          if [ "$WHICH_PIP3" != "$HOME/.local/bin/pip3" ]; then
            echo "pip3 not installed, installing by downloading get-pip.py"
            dpkg -l python3-distutils
            DISTUTILS_RET=$?
            if [ $DISTUTILS_RET -ne 0 ]; then
              echo "python distutils not found"
              echo "dkpg -l python3-distutils is non zero"
              return
            fi
            if [ ! -f "$DOTFILES_SCRIPT_PARENT/faaltu/get-pip.py" ]; then
              curl https://bootstrap.pypa.io/get-pip.py -o ${DOTFILES_SCRIPT_PARENT}/faaltu/get-pip.py
            fi
            /usr/bin/python3 $DOTFILES_SCRIPT_PARENT/faaltu/get-pip.py --user
          fi
          pip3 install --user virtualenv
          VIRTUALENV_EXEC="$HOME/.local/bin/virtualenv"
          if [ "$?" != "0" ]; then
            echo "Error in installing virtualenv through pip"
            echo "Command tried"
            echo "/usr/bin/python3 -m pip install --user virtualenv"
            return
          fi
        else
          /usr/bin/python3 -m pip install --user virtualenv
          VIRTUALENV_EXEC="$HOME/.local/bin/virtualenv"
          if [ "$?" != "0" ]; then
            echo "Error in installing virtualenv through pip"
            echo "Command tried"
            echo "/usr/bin/python3 -m pip install --user virtualenv"
            return
          fi
        fi
      fi
    fi
  fi
  # virtualenv should be in VIRTUALENV_EXE at this point
  if [ "$VERSION_NUMBER" != "2" ] && [ "$VERSION_NUMBER" != "3" ]; then
    echo "From python_virtualenv_setup: $VERSION_NUMBER is not supported"
    return
  else
    if [ "$VERSION_NUMBER" == "2" ]; then
      # /usr/bin/python2
      if [ ! -f /usr/bin/python2 ] && [ ! -L /usr/bin/python2 ]; then
        echo "From python_virtualenv_setup: Cannot find /usr/bin/python2"
      else
        $VIRTUALENV_EXEC -p /usr/bin/python2 $HOME/venv2
      fi
    elif [ "$VERSION_NUMBER" == "3" ]; then
      # /usr/bin/python3
      if [ ! -f /usr/bin/python3 ] && [ ! -L /usr/bin/python3 ]; then
        echo "From python_virtualenv_setup: Cannot find /usr/bin/python3"
      else
        $VIRTUALENV_EXEC -p /usr/bin/python3 $HOME/venv
      fi
    fi
  fi
}

python_virtualenv_setup 3

if [ -f /usr/bin/pip3 ] || [ -L /usr/bin/pip3 ]; then
  if [ ! -f $HOME/.local/bin/cmakelint ]; then
    /usr/bin/pip3 install --user cmakelint
  fi
  if [ ! -f $HOME/.local/bin/cmake-format ]; then
    /usr/bin/pip3 install --user cmake-format
  fi
fi

# all symlink done (configuration structure established)

update_bashrc "force_color_prompt=yes" $NEED_BASH_REFRESH "force_color_prompt already set" \
              "sed -i 's/#force_color_prompt/force_color_prompt/g' ~/.bashrc"
if [ $NEED_BASH_REFRESH -eq 0 ] && [ $REFRESH -ne 0 ] && [ $DEBUG_SCRIPT -ne 0 ]; then
  echo "force_color_prompt is setting NEED_BASH_REFRESH"
fi
NEED_BASH_REFRESH=$REFRESH

update_bashrc DOTFILES_SCRIPT_PARENT=$SCRIPTPATH $NEED_BASH_REFRESH "DOTFILES_SCRIPT_PARENT env var set"
if [ $NEED_BASH_REFRESH -eq 0 ] && [ $REFRESH -ne 0 ] && [ $DEBUG_SCRIPT -ne 0 ]; then
  echo "DOTFILES_SCRIPT_PARENT is setting NEED_BASH_REFRESH"
fi
NEED_BASH_REFRESH=$REFRESH

update_bashrc "export DOTFILES_SCRIPT_PARENT" $NEED_BASH_REFRESH "DOTFILES_SCRIPT_PARENT env already exported"
if [ $NEED_BASH_REFRESH -eq 0 ] && [ $REFRESH -ne 0 ] && [ $DEBUG_SCRIPT -ne 0 ]; then
  echo "export DOTFILES_SCRIPT_PARENT is setting NEED_BASH_REFRESH"
fi
NEED_BASH_REFRESH=$REFRESH


update_bashrc "source ~/.my_bashrc" $NEED_ENTRY_REFRESH "removing source ~/.my_bashrc" \
              "sed -i '/source ~\/.my_bashrc/d' ~/.bashrc"
if [ $NEED_BASH_REFRESH -eq 0 ] && [ $REFRESH -ne 0 ]; then
  REFRESH=0
else
  NEED_BASH_REFRESH=1
  if [ $DEBUG_SCRIPT -ne 0 ]; then
    echo "removing ~/.my_bashrc is setting NEED_BASH_REFRESH"
  fi
fi
NEED_BASH_REFRESH=$REFRESH

update_bashrc "source ~/.my_profile" $NEED_ENTRY_REFRESH "removing source ~/.my_profile" \
              "sed -i '/source ~\/.my_profile/d' ~/.bashrc"
if [ $NEED_BASH_REFRESH -eq 0 ] && [ $REFRESH -ne 0 ]; then
  REFRESH=0
else
  NEED_BASH_REFRESH=1
  if [ $DEBUG_SCRIPT -ne 0 ]; then
    echo "removing ~/.my_profile is setting NEED_BASH_REFRESH"
  fi
fi
NEED_BASH_REFRESH=$REFRESH

update_bashrc "source ~/.my_entry" $NEED_ENTRY_REFRESH "already calling ~/.my_entry"
if [ $NEED_ENTRY_REFRESH -eq 0 ] && [ $REFRESH -ne 0 ]; then
  echo "souce ~/.my_entry is setting NEED_ENTRY_REFRESH"
fi
NEED_ENTRY_REFRESH=$REFRESH

if [[ $DEBUG_SCRIPT -ne 0 ]]; then
echo "bef val of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_ENTRY_REFRESH"
fi

if [[ NEED_BASH_REFRESH -ne 0 ]]; then
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
     echo "sourcing bashrc"
  fi
  #source ~/.bashrc # cannot source bashrc from script
  source ~/.my_entry "$SCRIPTPATH"
  NEED_ENTRY_REFRESH=0
fi

if [[ $DEBUG_SCRIPT -ne 0 ]]; then
  echo "after bash of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_ENTRY_REFRESH"
fi

if [[ NEED_ENTRY_REFRESH -ne 0 ]]; then
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
     echo "sourcing my_entry"
  fi
  source ~/.my_entry
fi

# all updating to variable/dotfiles done
#calling install functions
# install_ncurses
uninstall_local_vim # this is a hack to get around the fact that vim is installed in the ~/.local directory
# install_vim
uninstall_brew_neovim # till brew nvim is < 0.6
install_github_neovim
uninstall_clang_llvm
#install_clang_llvm
install_ctags # giving error for now
install_gitlfs
# install_jq
# install_i3wmIPC
install_cmake
#install_ycm
install_conan
install_compiledb
install_doxygen
install_breathe_and_sphnix
install_vcpkg
# install_valgrind
#install_gperftools
install_node
# install_act
#install_cppcheck
#install_cmake_language_server
#install_bash_language_server
#install_digestif_language_server  # for latex
#install_python_language_server

if [[ $DEBUG_SCRIPT -ne 0 ]]; then
  echo "after prof val of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_ENTRY_REFRESH"
fi

