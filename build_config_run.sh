#!/usr/bin/env bash
# Paulo Aleixo Campos
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__dbg_on_off=on  # on off
function shw_info { echo -e '\033[1;34m'"$1"'\033[0m'; }
function error { echo "ERROR in ${1}"; exit 99; }
trap 'error $LINENO' ERR
function dbg { [[ "$__dbg_on_off" == "on" ]] || return; echo -e '\033[1;34m'"dbg $(date +%Y%m%d%H%M%S) ${BASH_LINENO[0]}\t: $@"'\033[0m';  }
exec > >(tee -i /tmp/$(date +%Y%m%d%H%M%S.%N)__$(basename $0).log ) 2>&1
set -o errexit
  # NOTE: the "trap ... ERR" alreay stops execution at any error, even when above line is commente-out
set -o pipefail
set -o nounset
set -o xtrace


build_image() {
  shw_info "############ build_image ################"
  mkdir -p data && sudo chmod -Rv o+rX data \
  && docker build -t privprosody .
}


generate_certs() {
  shw_info "############ generate_certs ################"
  ./remake_certs_files_and_subdirs.sh $DOMAIN
}


clean_data() {
  shw_info "############ clean_data ################"
  if [[ -d data ]]; then
    sudo rm -rfv ./data
    mkdir -p data && sudo chmod -Rv o+rX data
  fi
}


register_users() {
  shw_info "############ register_users ################"
  for a_user in "${@}"; do
    THE_NEW_USER=$a_user
    THE_NEW_PASSWORD=112233
    THE_DOMAIN=$DOMAIN
    
    stop_container
    docker run --rm \
       -e DOMAIN=${THE_DOMAIN} \
       -e ALLOW_REGISTRATION=false \
       -v $PWD/certs:/usr/local/etc/prosody/certs \
       -v $PWD/data:/usr/local/var/lib/prosody:rw \
       privprosody \
       register ${THE_NEW_USER} ${THE_DOMAIN} ${THE_NEW_PASSWORD}
    sleep 3 
  done
}

run_detach_container() {
  stop_container
  
  sudo chmod -vR o+rwX data
  sudo chmod -vR o+rX certs
  docker run -d \
     --name pros \
     -p 5000:5000 \
     -p 5222:5222 \
     -p 5223:5223 \
     -p 5269:5269 \
     -p 5281:5281 \
     -e DOMAIN=$DOMAIN \
     -e PROSODY_ADMINS=admin \
     -e ALLOW_REGISTRATION=false \
     -e E2E_POLICY_CHAT=optional \
     -e E2E_POLICY_MUC=optional \
     -v $PWD/certs:/usr/local/etc/prosody/certs \
     -v $PWD/data:/usr/local/var/lib/prosody:rw \
     privprosody

  sleep 3
  docker logs pros
}

stop_container() {
  #shw_info "############ stop_container ################"
  if [[ "$( docker container inspect -f '{{.State.Running}}' pros 2>/dev/null)" == "true" ]]; then
    docker stop pros && docker rm pros
    sleep 3
  fi
}


show_url_and_open_webclient() {
  shw_info "############ show_url_and_open_webclient ################"
  echo https://$DOMAIN:5281/conversejs
  (xdg-open https://$DOMAIN:5281/conversejs &>/dev/null &)
}


main() {
  [[ "${1-}" ]] || {
    cat <<EOT
  USAGE: $0 my.do.ma.in
  EX:    $0 10.147.17.38.xip.io
EOT
    exit 1
  }
  DOMAIN="${1}"

  cd "${__dir}"
  build_image
  generate_certs
  clean_data
  run_detach_container
  stop_container
  register_users admin user1 user2
  run_detach_container
  show_url_and_open_webclient
  shw_info "################# FINISHED SUCCESSFULLY! ######################"
}
main "${@}"


