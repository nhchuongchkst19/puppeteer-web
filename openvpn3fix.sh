#!/bin/env bash

install () {
  if [ -f "/usr/libexec/openvpn3-linux/openvpn3-run-wrapper" ]; then echo "Already installed, exiting."; exit; fi
  rm -rf /tmp/openvpn3-workaround
  mkdir /tmp/openvpn3-workaround
  cd /tmp/openvpn3-workaround || exit
  wget https://linux.yz.yamagata-u.ac.jp/ubuntu/pool/main/g/glib2.0/libglib2.0-0_2.74.3-0ubuntu1.2_amd64.deb
  ar x libglib2.0-0_2.74.3-0ubuntu1.2_amd64.deb
  tar --zstd -xvf data.tar.zst
  sudo mkdir -p /usr/libexec/openvpn3-linux/glib2
  sudo cp usr/lib/x86_64-linux-gnu/libg* /usr/libexec/openvpn3-linux/glib2/
  cd /usr/libexec/openvpn3-linux || exit
  sudo bash -c 'cat > openvpn3-run-wrapper' <<'EOF'
#!/bin/bash
LD_PRELOAD="/usr/libexec/openvpn3-linux/glib2/libglib-2.0.so.0.7400.3 /usr/libexec/openvpn3-linux/glib2/libgobject-2.0.so.0.7400.3 /usr/libexec/openvpn3-linux/glib2/libgio-2.0.so.0.7400.3" ${0}.bin $*
EOF
  sudo chmod +x ./openvpn3-run-wrapper
  sudo bash -c 'for f in openvpn3-service*; do if [ -f $f ]; then echo "$f -> $f.bin"; mv $f $f.bin; ln -s openvpn3-run-wrapper $f; fi; done'
}

uninstall() {
  cd /usr/libexec/openvpn3-linux || exit
  sudo rm -rf /usr/libexec/openvpn3-linux/glib2
  sudo rm -f /usr/libexec/openvpn3-linux/openvpn3-run-wrapper
  sudo bash -c 'for f in openvpn3-service*; do if [ -L $f ]; then echo "$f.bin -> $f"; mv $f.bin $f; fi; done'
  sudo rm openvpn3-service-*.bin
}

reinstall_openvpn3_client() {
  sudo apt-get remove openvpn3
  sudo apt-get install openvpn3
}

case "$1" in
  install)
    install
    ;;
  uninstall)
    uninstall
    ;;
  reinstall_openvpn3_client)
    reinstall_openvpn3_client
    ;;
  *)
    echo "Usage: $0 {install|uninstall|reinstall_openvpn3_client}"
    exit 1
esac
