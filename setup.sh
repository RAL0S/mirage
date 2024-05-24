#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]; then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  sudo apt update
  sudo apt install --yes python3-pip libhackrf-dev

  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $RALPM_TMP_DIR/cpython-3.9.13.tar.gz
  tar xf $RALPM_TMP_DIR/cpython-3.9.13.tar.gz -C $RALPM_PKG_INSTALL_DIR/
  rm $RALPM_TMP_DIR/cpython-3.9.13.tar.gz

  $RALPM_PKG_INSTALL_DIR/python/bin/pip3.9 install 'keyboard>=0.13.5' 'psutil>=5.7.2' 'pyserial>=3.5' 'pyusb>=1.1.0' 'terminaltables>=3.1.0' 'scapy>=2.4.5rc1.dev51' 'pycryptodomex>=3.8.2' 'matplotlib>=2.2.2'

  wget https://github.com/RCayre/mirage/archive/f73f6c4442e4bfd239eb5caf5e1283c125d37db9.tar.gz -O $RALPM_TMP_DIR/mirage.tar.gz
  tar xf $RALPM_TMP_DIR/mirage.tar.gz -C $RALPM_PKG_INSTALL_DIR/
  rm $RALPM_TMP_DIR/mirage.tar.gz

  cd $RALPM_PKG_INSTALL_DIR/mirage*
  sudo $RALPM_PKG_INSTALL_DIR/python/bin/python3 setup.py install

  ln -s $RALPM_PKG_INSTALL_DIR/mirage_launcher $RALPM_PKG_BIN_DIR/mirage_launcher
}

uninstall() {
  rm -rf $RALPM_PKG_INSTALL_DIR/python
  rm -rf $RALPM_PKG_INSTALL_DIR/mirage
  rm $RALPM_PKG_BIN_DIR/mirage_launcher
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1
