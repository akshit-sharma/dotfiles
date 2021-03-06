# /bin/bash

NEED_VIM_PLUGIN_INSTALL=1
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

  echo "running "
  echo "cat ~/.bashrc | grep -xqFe \"$LINE\""
  cat ~/.bashrc | grep -xqFe "$LINE"
  RET_CAT=$?
  if [ $RET_CAT -eq 0 ];
  then
    if [[ $DEBUG_SCRIPT -ne 0 ]]; then
      echo "~/.bashrc $MSG_IF_PRESENT"
    fi
  else
    if [ "$LINE" = "$CMD" ]; then 
      echo "" >> ~/.bashrc
      echo "$LINE" >> ~/.bashrc
    else 
      eval $CMD
    fi
    REFRESH=1
  fi
}

#1 command to run to get version
#2 version to statisfied
function version_statisfied {
  currentver="$1"
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
  echo "setting NEED_ENTRY_REFRESH to 1"
  NEED_ENTRY_REFRESH=1
else
  echo "setting NEED_ENTRY_REFRESH to 0"
  NEED_ENTRY_REFRESH=0
fi

# if called by other script
if [ $SHLVL -gt 2 ]; then  
  if [ -z "$2" ]; then
    NEED_VIM_PLUGIN_INSTALL=1
  else
    NEED_VIM_PLUGIN_INSTALL=0
  fi
fi

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

# install anaconda3
function install_anaconda3 {
  CONDA_YEAR="2019"
  CONDA_MINOR_VERSION="10"
  CONDA_SCRIPT_FILE="Anaconda3-${CONDA_YEAR}.${CONDA_MINOR_VERSION}-Linux-x86_64.sh"
  CONDA_URL="https://repo.anaconda.com/archive/${CONDA_SCRIPT_FILE}"
  CONDA_DOWNLOAD_DIR=${SCRIPTPATH}/faaltu/anaconda3
  CONDA_INSTALL_DIR=${HOME}/anaconda3

  CONDA_MD5="b77a71c3712b45c8f33c7b2ecade366c"

  if [ ! -f ${CONDA_DOWNLOAD_DIR}/${CONDA_SCRIPT_FILE} ]; then
    download_and_extract ${CONDA_DOWNLOAD_DIR} ${CONDA_DOWNLOAD_DIR} ${CONDA_SCRIPT_FILE} ${CONDA_URL} ${CONDA_MD5}
  fi

  if [ ! -f ${CONDA_DOWNLOAD_DIR}/${CONDA_SCRIPT_FILE} ]; then
    echo "${CONDA_DOWNLOAD_DIR}/${CONDA_SCRIPT_FILE} not found"
    echo "anaconda3 install unsuccessful"
    return
  fi

  # --- script available for install ---

  if [ -f ${CONDA_INSTALL_DIR}/bin/conda ]; then
    echo "anaconda3 already installed"
    return
  fi

  # --- anaconda3 not installed or reinstall ---

  if [ -d ${CONDA_INSTALL_DIR} ]; then
    rm -r ${CONDA_INSTALL_DIR}
  fi

  ${CONDA_DOWNLOAD_DIR}/${CONDA_SCRIPT_FILE} -b -f -p ${CONDA_INSTALL_DIR}
  
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

    VIM_MD5="b35e794140c196ff59b492b56c1e73db"
    VIM_VER="8.0"
    VIM_DIR="vim${VIM_VER}"
    VIM_TAR="vim-${VIM_VER}.tar.bz2"
    VIM_URL="https://ftp.nluug.nl/pub/vim/unix/${VIM_TAR}"

    VIM_INSTALL="1"

    if [ ! -d ${SCRIPTPATH}/faaltu/vim/bin ]; then
      VIM_INSTALL="0"
    else
      VIM_CURRENT_VER=`eval ${SCRIPTPATH}/faaltu/vim/bin/vim --version | head -n1 | cut -d' ' -f5`
      if [ "${VIM_INSTALL_VER}" != "${VIM_MAJOR_VER}.${VIM_MINOR_VER}" ]; then
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
        echo "(cd ${SCRIPTPATH}/faaltu/${VIM_DIR} && ./configure --enable-python3interp --with-features=huge --enable-gui=auto --prefix=$HOME/.local )"
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
    CTAGS_VER="5.8"
    CTAGS_DIR="ctags-${CTAGS_VER}"
    CTAGS_TAR="ctags-${CTAGS_VER}.tar.gz"
    CTAGS_URL="https://superb-dca2.dl.sourceforge.net/project/ctags/files/ctags/${CTAGS_VER}/${CTAGS_TAR}"
    CTAGS_INSTALL="0"
  
    ctags --version 2>&1> script_output.txt
    CTAGS_RET="$?"

    $HOME/bin/ctags --version 2>&1> script_output.txt
    MY_CTAGS_RET="$?"

    if [[ $CTAGS_RET != 0 ]] && [[ $MY_CTAGS_RET != 0 ]]; then

      echo "ctags download link broken"
      echo "not downloading"
      return

      if [ ! -f "$SCRIPTPATH/faaltu/$CTAGS_TAR" ]; then
        download_and_extract $SCRIPTPATH/faaltu/ $SCRIPTPATH/faaltu/$CTAGS_DIR $CTAGS_TAR $CTAGS_URL $CTAGS_MD5
        CTAGS_INSTALL=1
      elif [ ! -f $HOME/bin/ctags ]; then
        CTAGS_INSTALL=1
      fi
      if [[ $CTAGS_INSTALL == 1 ]]; then
        if [ -f "$SCRIPTPATH/faaltu/$CTAGS_DIR/configure" ]; then
          (cd $SCRIPTPATH/faaltu/$CTAGS_DIR/ && ./configure --prefix=$HOME)
          make -C $SCRIPTPATH/faaltu/$CTAGS_DIR 2>&1> script_output.txt
          make -C $SCRIPTPATH/faaltu/$CTAGS_DIR install 2>&1> script_output.txt
        else
          echo "$SCRIPTPATH/faaltu/$CTAGS_DIR/configure not found"
        fi
      fi 
    else 
      echo "CTAGS found, not installing again"
    fi
  fi
}

# install clang+llvm only if not installed or MD5 changed
function install_clang_llvm {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing clang+llvm"
  fi
  if [ $WGET_RET -ne 0 ]; then 
    echo "wget not found, cannot download LLVM Pre Binary"
  fi

  echo "wget found"
  LLVM_PREBINARY_VER="11.0.1"
  LLVM_PREBINARY_DIR="clang+llvm-${LLVM_PREBINARY_VER}-x86_64-linux-gnu-ubuntu-16.04"
  LLVM_PREBINARY_TAR="${LLVM_PREBINARY_DIR}.tar.xz"
  LLVM_PREBINARY_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_PREBINARY_VER}/${LLVM_PREBINARY_TAR}"
  LLVM_CLEAN_PREFIX="clang+llvm-*"
  LLVM_INSTALL=false

  CLANG_HOME=${SCRIPTPATH}/faaltu/clang+llvm
  cmd="${CLANG_HOME}/bin/clang -dumpversion"
  currentver=$($cmd)

  if [ ! -L "${CLANG_HOME}" ]; then
    LLVM_INSTALL=true 
  else
    if [ ! -f ${CLANG_HOME}/bin/clang ]; then
      LLVM_INSTALL=true
    elif $(version_statisfied "$currentver" "$LLVM_PREBINARY_VER"); then
      echo "clang_llvm version statisfied"
      echo "returning......"
      return
    else
      LLVM_INSTALL=true
    fi
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
    git lfs --version 
    if [ "$?" != 0 ]; then
      echo "git lfs not found"
      # download and install lfs
      GIT_LFS_INSTALL="0"
    else 
      echo "git lfs already found"
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
    echo "install of git lfs set to true"
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

  make --version
  MAKE_RET=$?
  cmake --version
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
  CMAKE_MD5="3793dcb86c0a358c8ee654d5b9ebb2dd"
  CMAKE_VER="3.19"
  CMAKE_SUB_VER="1"
  CMAKE_DIR="cmake"
  CMAKE_SCRIPT="cmake-${CMAKE_VER}.${CMAKE_SUB_VER}-Linux-x86_64.sh"
  CMAKE_URL="https://cmake.org/files/v${CMAKE_VER}/${CMAKE_SCRIPT}"
 
  CMAKE_INSTALL_DIR="$HOME/Softwares/cmake/"
  CMAKE_CMD="--skip-license --exclude-subdir --prefix=${CMAKE_INSTALL_DIR}"

  if [ ! -d $CMAKE_INSTALL_DIR ]; then
    mkdir -p $CMAKE_INSTALL_DIR
  fi

  download_and_extract $SCRIPTPATH/faaltu/$CMAKE_DIR $SCRIPTPATH/faaltu/$CMAKE_DIR \
    $CMAKE_SCRIPT $CMAKE_URL $CMAKE_MD5 

  if [ $SCRIPT_SUCC -eq 1 ]; then
    $SCRIPTPATH/faaltu/$CMAKE_DIR/$CMAKE_SCRIPT $CMAKE_CMD
  fi

}

# install googletest
function install_googletest {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing googletest"
  fi
  GOOGLETEST_MD5="2e6fbeb6a91310a16efe181886c59596"
  GOOGLETEST_VER="1.8"
  GOOGLETEST_SUB_VER="1"
  GOOGLETEST_DIR="googletest-release-${GOOGLETEST_VER}.${GOOGLETEST_SUB_VER}"
  GOOGLETEST_FILE="release-${GOOGLETEST_VER}.${GOOGLETEST_SUB_VER}.tar.gz"
  GOOGLETEST_URL="https://github.com/google/googletest/archive/${GOOGLETEST_FILE}"

  GOOGLETEST_INSTALL_DIR="$HOME/Softwares/googletest/"
  GOOGLETEST_CMD="$CMAKE_INSTALL_PREFIX=${GOOGLETEST_INSTALL_DIR}"

  download_and_extract $SCRIPTPATH/faaltu/ $SCRIPTPATH/faaltu/$GOOGLETEST_DIR \
    $GOOGLETEST_FILE $GOOGLETEST_URL $GOOGLETEST_MD5

  GOOGLETEST_BUILD_DIR=${SCRIPTPATH}/faaltu/${GOOGLETEST_DIR}/build

  if [ $SCRIPT_SUCC -eq 1 ]; then
    if [ ! -d ${GOOGLETEST_BUILD_DIR} ]; then
      mkdir -p ${GOOGLETEST_BUILD_DIR}
    else 
      rm -rf ${GOOGLETEST_BUILD_DIR}/*
    fi
    (cd ${GOOGLETEST_BUILD_DIR} && cmake -G"Unix Makefiles" --build ${GOOGLETEST_BUILD_DIR} -DCMAKE_INSTALL_PREFIX=${GOOGLETEST_INSTALL_DIR} -Dgtest_build_samples=ON ..) 
    GT_CMAKE_BUILD_RET="$?"
    if [ $GT_CMAKE_BUILD_RET -ne 0 ]; then
      echo "error in running cmake"
      echo "cmake -G"Unix Makefiles" --build ${GOOGLETEST_BUILD_DIR} -DCMAKE_INSTALL_PREFIX=${GOOGLETEST_INSTALL_DIR} -Dgtest_build_samples=ON ${GOOGLETEST_BUILD_DIR}/.."
      echo "returning........................"
      return
    fi
    make -C $GOOGLETEST_BUILD_DIR -j 8 2>&1> script_output.txt
    BUILD_RET=$?
    if [ $BUILD_RET -ne 0 ]; then
      echo "error in running make"
      echo "make -C $GOOGLETEST_BUILD_DIR -j 8"
      echo "returning......................"
      return
    fi
    make -C $GOOGLETEST_BUILD_DIR install 2>&1> script_output.txt
    INSTALL_RET=$?
    if [ $INSTALL_RET -ne 0 ]; then
      echo "error in running make install"
      echo "make -C $GOOGLETEST_BUILD_DIR install"
      echo "returning......................"
      return
    fi
  else
    echo "skipping googletest install"
  fi

}

# install Homebrew
function install_brew {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing HomeBrew"
  fi
  if [ ! -d ${SCRIPTPATH}/faaltu/homebrew ]; then
    if [ -d $HOME/.linuxbrew ]; then
      rm -rf $HOME/.linuxbrew
    fi
    mkdir ${SCRIPTPATH}/faaltu/homebrew
  fi

  BREW_VER="3.0.6"
  BREW_URL="https://github.com/Homebrew/brew/archive/${BREW_VER}.tar.gz"
  BREW_EXTRACT_DIR=${SCRIPTPATH}/faaltu/brew-${BREW_VER}
  BREW_CLEAN_PREFIX="brew-*"
  BREW_LINK=${SCRIPTPATH}/faaltu/brew

  cmd="$HOME/.linuxbrew/bin/brew --version | head -n1 | cut -d' ' -f2 | cut -d'-' -f1"
  currentver=$($cmd)

  if [ ! -f ${BREW_LINK} ]; then
    echo "${BREW_LINK} not found"
  elif $(version_statisfied "$currentver" "$BREW_VER"); then
    echo "homebrew version statisfied"
    echo "returning......"
    return
  else
    rm ${BREW_LINK}
  fi

  download_and_extract ${SCRIPTPATH}/faaltu/ ${BREW_EXTRACT_DIR} brew-${BREW_VER}.tar.gz ${BREW_URL} false ${BREW_CLEAN_PREFIX}

  if [ ! -L ${BREW_LINK} ]; then
    ln -sT ${BREW_EXTRACT_DIR} ${BREW_LINK}
  fi

  if [ ! -L ${HOME}/.linuxbrew ]; then
    ln -sT ${BREW_LINK} ${HOME}/.linuxbrew
  fi

}

function install_node {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing neovim"
  fi
  type node
  if [ "$?" == 0 ]; then
    return
  fi
  brew install node
}


function install_neovim {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing neovim"
  fi
  type nvim
  if [ "$?" == 0 ]; then
    return
  fi
  brew install neovim
}

function install_act {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing act"
  fi
  type act
  if [ "$?" == 0 ]; then
    return
  fi
  brew install nektos/tap/act
}

function install_cppcheck {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing cppcheck"
  fi
  type cppcheck
  if [ "$?" == 0 ]; then
    return
  fi
  brew install cppcheck
}

function install_gperftools {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing gperftools"
  fi
  type pprof
  if [ "$?" == 0 ]; then
    return
  fi
  brew install gpertools
}

function install_ycm {
# install YouCompleteMe only if not installed or if YCM is updated
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing YouCompleteMe"
  fi
  make --version
  MAKE_RET=$?
  cmake --version
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
        CC=${SCRIPTPATH}/faaltu/clang+llvm/bin/clang CXX=${SCRIPTPATH}/faaltu/clang+llvm/bin/clang++ python3 $HOME/.vim/bundle/YouCompleteMe/install.py --clang-completer --clangd-completer --cmake-path /home/akshitsharma/Softwares/cmake/bin/cmake
        if [ "$?" != "0" ]; then
          echo "error running"
          echo "python3 $HOME/.vim/bundle/YouCompleteMe/install.py --clang-completer --clangd-completer"
          echo "returning......"
          return  
        fi
        echo $YCM_HASH > $SCRIPTPATH/faaltu/ycm.hash
        echo "Installed/Updated YouCompleteMe"
      else 
        echo "YouCompleteMe is latest"
      fi
    fi
  fi
}

function install_vcpkg {
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing vcpkg"
  fi
  type vcpkg
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
  type conan
  if [ "$?" == "0" ]; then 
    return
  fi
  type pip3
  pip3 install --user conan
 
}

function install_cmake_language_server {

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing cmake-language-server"
  fi
  type cmake-language-server
  if [ "$?" == "0" ]; then 
    return
  fi
  type pip3
  pip3 install --user cmake-language-server
 
}

function install_bash_language_server {

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing bash-language-server"
  fi
  type bash-language-server
  if [ "$?" == "0" ]; then 
    return
  fi
  type npm
  npm i -g bash-language-server
 
}

function install_digestif_language_server { # for latex

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing digestif"
  fi
  type digestif
  if [ "$?" == "0" ]; then 
    return
  fi
  type luarocks
  luarocks install digestif

}

function install_python_language_server {
 
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing python-language-server"
  fi
  type cmake-language-server
  if [ "$?" == "0" ]; then 
    return
  fi
  type pip3
  pip3 install --user 'python-language-server[all]'
 
}

function install_doxygen {
  
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing doxygen"
  fi
  type doxygen
  if [ "$?" == "0" ]; then
    return
  fi
  type cmake
  type make

  DOXYGEN_CORRECT_MD5="7997a15c73a8bd6d003eaba5c2ee2b47"
  DOXYGEN_VER="1.8.17"
  DOXYGEN_DIR="doxygen-${DOXYGEN_VER}.src"
  DOXYGEN_SRC_DIR="doxygen-${DOXYGEN_VER}"
  DOXYGEN_BUILD_DIR="doxygen-${DOXYGEN_VER}/build"
  DOXYGEN_TAR="doxygen-${DOXYGEN_VER}.src.tar.gz"
  DOXYGEN_URL="http://doxygen.nl/files/${DOXYGEN_TAR}" 

  DOXYGEN_INSTALL_DIR="$HOME/Softwares/doxygen/"
  DOXYGEN_CMAKE_CMD="-B${SCRIPTPATH}/faaltu/${DOXYGEN_BUILD_DIR} -H${SCRIPTPATH}/faaltu/${DOXYGEN_SRC_DIR} -DCMAKE_INSTALL_PREFIX=${DOXYGEN_INSTALL_DIR}"
 
  type doxygen
  if [ "$?" == 0 ]; then
    return
  fi

  if [[ ! -f "${SCRIPTPATH}/faaltu/${DOXYGEN_BUILD_DIR}/CMakeCache.txt" ]]; then
    download_and_extract ${SCRIPTPATH}/faaltu ${SCRIPTPATH}/faaltu/${DOXYGEN_DIR} ${DOXYGEN_TAR} ${DOXYGEN_URL} ${DOXYGEN_CORRECT_MD5}
    if [[ ! -f "${SCRIPTPATH}/faaltu/${DOXYGEN_BUILD_DIR}/CMakeCache.txt" ]]; then
      mkdir ${SCRIPTPATH}/faaltu/${DOXYGEN_BUILD_DIR}
      cmake ${DOXYGEN_CMAKE_CMD}
      PREBUILD_RET="$?"
      if [ $PREBUILD_RET -ne 0 ]; then
        echo "error in running cmake"
        echo "cmake ${DOXYGEN_CMAKE_CMD}"
        echo "returning........................"
        return
      fi
     
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
  fi

}

function install_breathe_and_sphnix {

  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing breathe and sphinx"
  fi
  type sphinx-build
  if [ "$?" == "0" ]; then 
    return
  fi
  type pip3
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

# script for adding llvm to environment
home_dir_symlink llvm_scripts .
# script for adding gcc to environment
home_dir_symlink gcc_scripts .

if [ -d ~/.vim/syntax ]; then
  rm -rf ~/.vim/syntax
fi

# manual linking of dir inside ~/.vim 
home_dir_symlink syntax .vim
home_dir_symlink ftplugin .vim
home_dir_symlink templates .vim
home_dir_symlink colors .vim

# symlink directory for vimwiki
home_dir_symlink vimwiki .

# symlink i3 config
home_dir_symlink i3 .config
home_dir_symlink i3status .config

home_dir_symlink .gdbinit .

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

# plugin manager for vim
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
  NEED_VIM_PLUGIN_INSTALL=1
fi

if [ ! -d $HOME/.config ]; then
  mkdir $HOME/.config
fi

if [ -f $HOME/.nvim ]; then
  rm $HOME/.nvim
fi

home_dir_symlink .vimrc .
home_dir_symlink nvim .config
home_dir_symlink yapf .config
home_dir_symlink .flake8 .
home_dir_symlink .pylintrc .
home_dir_symlink .my_ssh_agent .
home_dir_symlink .my_profile .
home_dir_symlink .my_bashrc .
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
      echo "virtualenv for python3 exists ($HOME/venv)"
      return
    fi
  fi

  if [ -d "$HOME/venv2" ]; then
    if [ "$VERSION_NUMBER" == "2" ]; then
      echo "virtualenv for python2 exists ($HOME/venv2)"
      return
    fi
  fi

  type $VIRTUALENV_EXEC 
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
        $VIRTUALENV_EXEC -p /usr/bin/python3.7 $HOME/venv
      fi
    fi
  fi
}

python_virtualenv_setup 2
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


  echo "bef val of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_ENTRY_REFRESH"

if [[ NEED_BASH_REFRESH -ne 0 ]]; then
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
     echo "sourcing bashrc"
  fi
  #source ~/.bashrc # cannot source bashrc from script
  source ~/.my_entry "$SCRIPTPATH"
  NEED_ENTRY_REFRESH=0
fi

echo "after bash of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_ENTRY_REFRESH"

if [[ NEED_ENTRY_REFRESH -ne 0 ]]; then
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
     echo "sourcing my_entry"
  fi
  source ~/.my_entry
fi

# all updating to variable/dotfiles done
#calling install functions
# install_ncurses
# install_vim
uninstall_local_vim
install_anaconda3
install_clang_llvm
install_ctags
install_gitlfs
# install_i3wmIPC
install_cmake
install_googletest
install_ycm
install_conan
install_doxygen
install_breathe_and_sphnix
install_vcpkg
install_valgrind
install_gperftools
install_node
install_neovim
install_act
install_cppcheck
install_cmake_language_server
install_bash_language_server
install_digestif_language_server  # for latex
install_python_language_server

echo "after prof val of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_ENTRY_REFRESH"

if [[ NEED_VIM_PLUGIN_INSTALL -ne 0 ]]; then
  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
     echo "running vim +PluginInstall...."
  fi
  VIM_PLUGIN_HASH=$(cat $HOME/.vimrc | sed -n 's/\(^Plugin\)/\1/p' | md5sum | cut -d' ' -f1)
  VIM_EXEC=vim
  # if [ -f $HOME/.local/bin/vim ]; then
  #   VIM_EXEC=$HOME/.local/bin/vim
  # fi
  type $VIM_EXEC
  VIM_RET="$?"
  if [ ${VIM_RET} -eq "0" ]; then
    if [ ! -f $SCRIPTPATH/faaltu/.vim_plugin.hash ]; then
      VIM_PLUGIN_OLD_HASH="Nothing"
      $VIM_EXEC +PluginInstall +qall
    else
      VIM_PLUGIN_OLD_HASH=$(cat $SCRIPTPATH/faaltu/.vim_plugin.hash)
    fi
    if [ "$VIM_PLUGIN_HASH" != "$VIM_PLUGIN_OLD_HASH" ]; then
      $VIM_EXEC +PluginClean! +qall
      $VIM_EXEC +PluginInstall +qall
      $VIM_EXEC +PluginUpdate +qall
      echo $VIM_PLUGIN_HASH > $SCRIPTPATH/faaltu/.vim_plugin.hash
    fi
  fi

fi

# # install vim-ycm-latex-semantic-completer
#  if [[ $DEBUG_SCRIPT -ne 0 ]]; then
#    echo "install latex ycm for vim"
#  fi
#  YCM_COMPLETERS_DIR="$HOME/.vim/bundle/YouCompleteMe/third_party/ycmd/ycmd/completers"
#  if [ -d $YCM_COMPLETERS_DIR ]; then
#    if [ ! -d $YCM_COMPLETERS_DIR/tex/.git ]; then
#      git clone git@github.com:Cocophotos/vim-ycm-latex-semantic-completer.git $YCM_COMPLETERS_DIR/tex
#    fi
#    git -C $YCM_COMPLETERS_DIR/tex pull
#  else
#    echo "$YCM_COMPLETERS_DIR not found, cannot install vim-ycm-latex_semantic-completer"
#  fi


