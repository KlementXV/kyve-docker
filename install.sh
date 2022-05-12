#!/bin/bash

LINK_CSV='https://raw.githubusercontent.com/clementlvx/kyve-docker/main/data/pools.csv'
LINK_COMPOSE='https://raw.githubusercontent.com/clementlvx/kyve-docker/main/docker-compose.yml'

import_csv() {
   wget ${LINK_CSV} -O .pools.csv
   pools_csv=()
   while IFS= read -r line
   do
   pools_csv+=("$line")
   done < <(tail -n +2 .pools.csv)
   rm .pools.csv
}

csv_pools_names() {
   import_csv
   index=0
   for record in "${pools_csv[@]}"
   do
      pools_names+="$(echo $record | cut -d ";" -f2) "
      ((index++))
   done
}

dl_node() {
   git clone $1 $pool_selected_Name
}

dl_compose() {
   wget $LINK_COMPOSE
}

change_compose() {
    sed -i "s/NODE_NAME/${pool_selected_Name}/" docker-compose.yml
    sed -i "s/THE_MNEMONIC/${node_mnemonic}/" docker-compose.yml
    sed -i "s/THE_STACKE/$node_stacke/" docker-compose.yml
}

req_variables() {
   read -p "Mnemonic:" node_mnemonic
   read -p "Initial Stake:" node_stacke 
}

choose_pool() {
   csv_pools_names
   echo "Select in which pool you want to create your node"
   PS3="Pool : "
   select character in $pools_names
   do
      echo "Selected pool: $character"
      req_variables
      pool_selected_id=$(($REPLY-1))
      pool_selected_Name=$(echo ${pools_csv[$pool_selected_id]} | cut -d ";" -f2)
      pool_selected_Link=$(echo ${pools_csv[$pool_selected_id]} | cut -d ";" -f3)

      dl_node $pool_selected_Link
      cp ./arweave.json $pool_selected_Name
      cd $pool_selected_Name
      dl_compose
      change_compose
      sudo docker-compose up -d
      exit
   done
}

clear
choose_pool
