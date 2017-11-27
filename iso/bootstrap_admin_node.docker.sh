#!/bin/bash

function countdown() {
  local i
  sleep 1
  for ((i=$1-1; i>=1; i--)); do
    printf '\b\b%02d' "$i"
    sleep 1
  done
}

function fail() {
  echo "ERROR: Fuel node deployment FAILED! Check /var/log/puppet/bootstrap_admin_node.log for details" 1>&2
  exit 1
}
# LANG variable is a workaround for puppet-3.4.2 bug. See LP#1312758 for details
export LANG=en_US.UTF8
showmenu="no"
if [ -f /root/.showfuelmenu ]; then
  . /root/.showfuelmenu
fi

activeiface=$(facter interfaces | sed 's/,/\n/g' | grep -E '^eth|^en' | head -1)

echo -n "Applying default Fuel settings..."
fuelmenu --save-only --iface="$activeiface"
echo "Done!"

if [[ "$showmenu" == "yes" || "$showmenu" == "YES" ]]; then
  fuelmenu
  else
  #Give user 15 seconds to enter fuelmenu or else continue
  echo
  echo -n "Press a key to enter Fuel Setup (or press ESC to skip)... 15"
  countdown 15 & pid=$!
  if ! read -s -n 1 -t 15 key; then
    echo -e "\nSkipping Fuel Setup..."
  else
    { kill "$pid"; wait $!; } 2>/dev/null
    case "$key" in
      $'\e')  echo "Skipping Fuel Setup.."
              echo -n "Applying default Fuel setings..."
              fuelmenu --save-only --iface="$activeiface"
              echo "Done!"
              ;;
      *)      echo -e "\nEntering Fuel Setup..."
              fuelmenu
              ;;
    esac
  fi
fi
#Reread /etc/sysconfig/network to inform puppet of changes
. /etc/sysconfig/network
hostname "$HOSTNAME"

### docker stuff
images_dir="/var/www/nailgun/docker/images"

# extract docker images
mkdir -p $images_dir $sources_dir
rm -f $images_dir/*tar
pushd $images_dir &>/dev/null

echo "Extracting and loading docker images. (This may take a while)"
lrzip -d -o fuel-images.tar fuel-images.tar.lrz && tar -xf fuel-images.tar && rm -f fuel-images.tar
popd &>/dev/null
service docker start

# load docker images
for image in $images_dir/*tar ; do
    echo "Loading docker image ${image}..."
    docker load -i "$image"
    # clean up extracted image
    rm -f "$image"
done

# apply puppet
puppet apply --detailed-exitcodes -d -v /etc/puppet/modules/nailgun/examples/host-only.pp
if [ $? -ge 4 ];then
  fail
fi
rmdir /var/log/remote && ln -s /var/log/docker-logs/remote /var/log/remote

dockerctl check || fail

IMAGE_NAME='eayundeploy'
IMAGE_VERSION='latest'
# load eayundeploy docker image
docker load -i /usr/share/eayundeploy/eayundeploy-image.tar
if [ $? != 0 ];then
  echo "eayundeploy docker image load failed."
  fail
fi

# remove old container
if docker ps -a | grep -q eayundeploy;then
  docker rm -f eayundeploy
fi
# start eayundeploy container
docker run -d -p 9000:8000 --restart="always" -v /etc/fuel/:/etc/fuel/ -v /var/log/eayundeploy/:/var/log/eayundeploy/ --name eayundeploy $IMAGE_NAME:$IMAGE_VERSION
if [ $? != 0 ];then
  echo "eayundeploy container start failed."
  fail
fi

echo "Waiting for fuel to be ready..."
fuel_ready=0
retries=0

until [ $fuel_ready -eq 1 ]
do
    retries=$((retries+1))
    fuel plugins -l >/dev/null 2>&1;
    fp_ret=$?

    if [ $fp_ret -eq 0 ]; then
        fuel_ready=1
    elif [ $retries -gt 18 ]; then
        break
    else
        sleep 10
    fi
done

if [ $fuel_ready -eq 1 ]; then
    echo "Installing EayunStack Fuel Plugins..."
    for plugin in /opt/eayunstack/*.fp
    do
        if [ -f "$plugin" ]; then
            fuel plugins --install "$plugin"
        fi
    done
else
    echo "Fuel is not ready in 180 seconds."
    echo "Skipping EayunStack Fuel Plugins Installation."
fi

bash /etc/rc.local
echo "Fuel node deployment complete!"
