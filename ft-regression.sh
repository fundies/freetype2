#!/bin/bash

function build() {
  set -e # exit on error
  ./autogen.sh
  ./configure
  make
  pushd ..
  [[ -d ./freetype2-demos ]] || git clone git://git.sv.nongnu.org/freetype/freetype2-demos.git
  pushd freetype2-demos
  make
  popd
  popd
  set +e
}

if [ -z "$1" ]; then
  echo "No commit specified to check out master for regression tests."
  echo "Aborting!"
  exit 1
fi

if [ -z "$2" ]; then
  echo "No directory specified to check out master for regression tests."
  echo "Aborting!"
  exit 1
fi

export COMP_COMMIT_DIR="$2"

if [ -d "${COMP_COMMIT_DIR}" ]; then
  read -p "Remove existing directory ${COMP_COMMIT_DIR} (y/n)? " CONT
  if [ "$CONT" = "y" ]; then
    rm -rf "${COMP_COMMIT_DIR}"
  fi
fi

PREV_GIT_HASH=$(git log --pretty=format:'%h' -n 1)
export PREVIOUS_PWD=${PWD}

build
./ft-test.sh

echo "Copying ${PWD} to ${COMP_COMMIT_DIR}"
cp -p -r "${PWD}" "${COMP_COMMIT_DIR}"

pushd "${COMP_COMMIT_DIR}"

# clean before we checkout
make clean

if [[ "${PWD}" == "${COMP_COMMIT_DIR}" ]]; then
  git stash
  git clean -f -d
  git checkout "$1"
  GIT_HASH=$(git log --pretty=format:'%h' -n 1)
  build
  ${PREVIOUS_PWD}/ft-test.sh ${PREV_GIT_HASH} ${GIT_HASH}
  popd
else
  echo "Failed to change directory to ${COMP_COMMIT_DIR}. Something is horribly wrong..."
  echo "Aborting!"
  exit 1
fi

