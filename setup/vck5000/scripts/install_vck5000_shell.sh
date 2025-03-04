#!/usr/bin/env bash
# Copyright 2021 Xilinx Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

arch=$(uname -m)
kernel=$(uname -r)
if [ -n "$(command -v lsb_release)" ]; then
  distroname=$(lsb_release -s -d)
elif [ -f "/etc/os-release" ]; then
  distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')
elif [ -f "/etc/debian_version" ]; then
  distroname="Debian $(cat /etc/debian_version)"
elif [ -f "/etc/redhat-release" ]; then
  distroname=$(cat /etc/redhat-release)
else
  distroname="$(uname -s) $(uname -r)"
fi


##############################
# Download Gen3x4 Platform
##############################
if [[ $distroname == *"Ubuntu 18.04"* ]] || [[ $distroname == *"Ubuntu 20.04"* ]]; then
  echo "Ubuntu 18.04/20.04"
  DEPLOY_PLFM_URL="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-vck5000-prod-gen3x16-platform-1-3_all.deb.tar.gz"
elif [[ $distroname == *"CentOS"* ]] || [[ $distroname == *"Red Hat"* ]]; then
  echo "CentOS/RHEL"
  DEPLOY_PLFM_URL="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-vck5000-prod-gen3x16-platform-1-3.noarch.rpm.tar.gz"
else
  echo "Failed, couldn't detect os distribution"
  exit 1
fi

##############################
# Install Gen3x4 Platform
##############################
mkdir ./temp
cd ./temp
wget $DEPLOY_PLFM_URL -O shell.tgz
tar xfz shell.tgz
if [[ $distroname == *"Ubuntu 18.04"* ]] || [[ $distroname == *"Ubuntu 20.04"* ]]; then
  sudo apt install ./*sc-fw* -y
  sudo apt install ./*validate* -y
  sudo apt install ./*base* -y
elif [[ $distroname == *"CentOS"* ]] || [[ $distroname == *"Red Hat"* ]]; then
  sudo yum install ./*sc-fw* -y
  sudo yum install ./*validate* -y
  sudo yum install ./*base* -y
else
  echo "Failed, couldn't detect os distribution"
  exit 1
fi

cd ..
rm -rf ./temp
##############################
# Flash alveo
##############################
sudo /opt/xilinx/xrt/bin/xbmgmt flash --legacy --update --shell xilinx_vck5000_gen3x16_xdma_base_1
