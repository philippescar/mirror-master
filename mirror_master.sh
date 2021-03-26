#!/bin/bash

# Usage
function usage() {
  echo -e "\nDescription: This script uses skopeo to sync 2 docker registries please be sure to have the following environment variables in place:"
  echo -e "\nSOURCE_IMAGE, SOURCE_REGISTRY, DEST_REGISTRY, IGNORED_TAGS\n"
  echo -e "\nIf your source or destination registry needs authentication you will also need:\n"
  echo -e "\nDEST_AUTH_PWD/DEST_AUTH_USER and/or SOURCE_AUTH_PWD/SOURCE_AUTH_USER"
  exit 1
}

# Variables
read -a source_image <<< $SOURCE_IMAGE
dest_registry=$DEST_REGISTRY
dest_auth_pwd=$DEST_AUTH_PWD
dest_auth_user=$DEST_AUTH_USER
ignored_tags=$IGNORED_TAGS
source_registry=$SOURCE_REGISTRY
source_auth_pwd=$SOURCE_AUTH_PWD
source_auth_user=$SOURCE_AUTH_USER

# Checking Variables
if [ -z "$dest_registry" ] ; then
  echo -e "DEST_REGISTRY variable empty or missing"
  usage;
fi

if [ -z "$ignored_tags" ] ; then
  echo -e "IGNORED_TAGS variable empty or missing"
  usage;
fi

if [ -z "$source_image" ] ; then
  echo -e "SOURCE_IMAGE variable empty or missing"
  usage;
fi

if [ -z "$source_registry" ] ; then
  echo -e "SOURCE_REGISTRY variable empty or missing"
  usage;
fi

if [ ! -z "$dest_auth_pwd" ] ; then
  echo -e "Destination Registry Authentication found! \n"
  echo "$dest_auth_pwd" | docker login -u $dest_auth_user --password-stdin https://$dest_registry 
fi 

if [ ! -z "$source_auth_pwd" ] ; then
  echo -e "Source Registry Authentication found! \n"
  echo "$source_auth_pwd" | docker login -u $source_auth_user --password-stdin https://$source_registry
fi 

# Displaying Configuration
echo -e "\n Source Registry: $source_registry \n Destination Registry: $dest_registry \n Ignored Tags: $ignored_tags"

# Function
function copy_image() {
    skopeo sync --all --src docker --dest docker $source_registry/$i:$n $dest_registry/
}

# Interaction through images

for i in ${source_image[@]}; do
  external_tags=$(skopeo list-tags --tls-verify=false docker://$source_registry/$i | jq -r '.Tags')
  internal_tags=$(skopeo list-tags --tls-verify=false docker://$dest_registry/$i | jq -r '.Tags')
  array_diff=$(jq -n --argjson array1 "$external_tags" --argjson array2 "$internal_tags" '{"ext": $array1,"int":$array2} | .ext-.int' | grep -vE $ignored_tags | sed 's/"//g' | sed 's/[][]//g' | tr ',' '\n')

  for n in $array_diff; do
    copy_image;
  done
done
