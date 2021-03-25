#!/bin/bash

# Usage
function usage() {
  echo -e "\nDescription: This script uses skopeo to sync 2 docker registries please be sure to have the following environment variables in place:"
  echo -e "\nSOURCE_IMAGE, SOURCE_REGISTRY, DEST_REGISTRY, IGNORED_TAGS\n"
  exit 0
}

# Variables
read -a source_image <<< $SOURCE_IMAGE
source_registry=$SOURCE_REGISTRY
dest_registry=$DEST_REGISTRY
ignored_tags=$IGNORED_TAGS

# Checking Variables

if [ -z "$source_image" ] ; then
  echo -e "SOURCE_IMAGE variable empty or missing"
  usage;
fi

if [ -z "$source_registry" ] ; then
  echo -e "SOURCE_REGISTRY variable empty or missing"
  usage;
fi

if [ -z "$dest_registry" ] ; then
  echo -e "DEST_REGISTRY variable empty or missing"
  usage;
fi

if [ -z "$ignored_tags" ] ; then
  echo -e "IGNORED_TAGS variable empty or missing"
  usage;
fi

# Displaying Configuration
echo -e "\n Source Registry: $source_registry \n Destination Registry: $dest_registry \n Ignored Tags: $ignored_tags"

# Function
function copy_image() {
    echo -e "\nCopying the image $i:$n"
    skopeo copy --all -q docker://$source_registry/$i:$n docker://$dest_registry/$i:$n
}

# Interaction through images

for i in ${source_image[@]}; do
  external_tags=$(skopeo list-tags docker://$source_registry/$i | jq -r '.Tags')
  internal_tags=$(skopeo list-tags docker://$dest_registry/$i | jq -r '.Tags')
  array_diff=$(jq -n --argjson array1 "$external_tags" --argjson array2 "$internal_tags" '{"ext": $array1,"int":$array2} | .ext-.int' | grep -vE $ignored_tags | sed 's/"//g' | sed 's/[][]//g' | tr ',' '\n')

  for n in $array_diff; do
    copy_image;
  done
done
