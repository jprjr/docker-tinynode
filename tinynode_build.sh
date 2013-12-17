#!/usr/bin/env bash
set -e

imagename=tinynode

cdir=$(pwd)
source ./${imagename}_config

buildroot_dir=${cdir}/buildroot-${buildroot_version}
docker_dir=${cdir}/Docker

if [[ ! -d ${buildroot_dir} ]]
then
  curl ${buildroot_url} | tar jx
  cp ./${imagename}_defconfig ${buildroot_dir}/configs/${imagename}_defconfig
  cd ${buildroot_dir} && make ${imagename}_defconfig && make
  cd ${cdir}
else
  # Probably just doing a rebuild
  cp ./${imagename}_defconfig ${buildroot_dir}/configs/${imagename}_defconfig
  cd ${buildroot_dir}
  make ${imagename}_defconfig && make
  for package in "${packages[@]}"
  do
      echo "building ${package}"
      make ${package}-rebuild
  done
  make
  cd ${cdir}
fi

mv ${buildroot_dir}/output/images/rootfs.tar ${docker_dir}

