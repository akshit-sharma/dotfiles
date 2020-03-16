#!/bin/bash
# script for downloading cpp_starter_project 
# from github, followed by copying the files to
# project

set -e

if [ $DOTFILES_SCRIPT_PARENT ]; then
  CPP_PROJECT_HOME=$DOTFILES_SCRIPT_PARENT/cpp_project/cpp_starter_project
else
  echo "DOTFILES_SCRIPT_PARENT not set"
  exit 1
fi

SKIP_UPDATE=false
REPO_DIR=$CPP_PROJECT_HOME

if [ -z "$1" ]; then
  echo "Invalid argument"
  echo "call this script with folder to copy cpp_starter_project into"
  exit 5
fi

DESTINATION_FOLDER=$1

function check_internet {
  ping google.com -c 1 -t 100 > /dev/null
  NET_AVAILABLE="$?"
  if [ $NET_AVAILABLE != 0 ]; then
    SKIP_UPDATE=true
    echo "Ping returned ${NET_AVAILABLE}"
    echo "Internet not available, skipping update"
  fi
}

function github_update {
  if [ -d $REPO_DIR ]; then
    if [ "$SKIP_UPDATE" != "true" ]; then
      echo "REPO_DIR set to $REPO_DIR"
      git -C $REPO_DIR remote update

      UPSTREAM='@{u}'
      #' small work around for cleaner syntax in vim
      LOCAL=$(git -C $REPO_DIR rev-parse @)
      REMOTE=$(git -C $REPO_DIR rev-parse "$UPSTREAM")
      BASE=$(git -C $REPO_DIR merge-base @ "$UPSTREAM")

      if [ $LOCAL = $BASE ] && [[ ! ($LOCAL = $REMOTE) ]]; then

        echo "Need to pull"
        
        git -C $REPO_DIR pull origin master
        RET_GIT_PULL=$?

        if [ "$RET_GIT_PULL" != "0" ]; then
          echo "non-zero($RET_GIT_PULL) from git pull"
          echo "Possibly a conflict"
        fi

      elif [ $REMOTE = $BASE ] || [ $LOCAL = $REMOTE ]; then

        if [ $LOCAL = $REMOTE ]; then
        
          echo "Up-to-date"
        
        elif [ $REMOTE = $BASE ]; then 
       
          echo "Need to push"
          git -C $HOME/dotfiles push origin master
        
        fi

      else
        
        echo "Diverged"
        exit 2

      fi

    fi
  else
    if [ "$SKIP_UPDATE" != "true" ]; then
      git clone git@github.com:akshit-sharma/cpp_starter_project.git $REPO_DIR
    else
      echo "Internet not available and main github repository not available...."
      exit 3
    fi
  fi
}

# function for copying project files
# 1: folder containing source (where to copy from)
# 2: folder containing destination (where to copy to)
function copy_project_files {
  SRC_DIR=$1
  DST_DIR=$2

  if [ -d $DST_DIR ]; then
    if [ "$(ls -A $DST_DIR)" ]; then 
      echo "$DST_DIR should be empty"
      exit 4
    fi
  fi

  cp -r $SRC_DIR $DST_DIR
}

check_internet
github_update

echo "copying cpp_starter_project to ${DESTINATION_FOLDER}"

copy_project_files ${CPP_PROJECT_HOME} ${DESTINATION_FOLDER}

