#!/bin/bash

# Current stream metadata URLs
# Stable: https://builds.coreos.fedoraproject.org/streams/stable.json
# Testing: https://builds.coreos.fedoraproject.org/streams/testing.json
# Next: https://builds.coreos.fedoraproject.org/streams/next.json

die() {
    echo "$1"
    exit 1
}

while :; do
    case $1 in
        -h|-\?|--help)
            show_help
            exit
            ;;
        --artifact)
            if [ "$2" ]; then
                chosen_artifact=$2
                shift
            else
                die 'ERROR: "--artifact" requires a non-empty option argument.'
            fi
            ;;
	 --stream)
            if [ "$2" ]; then
                chosen_stream=$2
                shift
            else
                die 'ERROR: "--stream" requires a non-empty option argument.'
            fi
            ;;
	--library)
            if [ "$2" ]; then
                chosen_library=$2
                shift
            else
                die 'ERROR: "--library" requires a non-empty option argument.'
            fi
            ;;    
        -v|--verbose)
            verbose=$((verbose + 1))
            ;;
        --)
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)
            break
    esac

    shift
done

stream_data=$(curl -s https://builds.coreos.fedoraproject.org/streams/${chosen_stream}.json)
file_url=$(echo ${stream_data} | jq -r '.architectures.x86_64.artifacts.vmware.formats.ova.disk.location')
file_name=$(basename ${file_url})
template_name="${file_name%.*}"
template_exists=false

echo "Checking for ${template_name} in library ${LIBRARY}"
library_items=$(govc library.ls "${chosen_library}/*")
while IFS= read -r line; do
  library_item_name=$(echo  ${line} | cut -d'/' -f 3)
  echo "Library Item: $library_item_name"
  if [[ "$library_item_name" ==  "$template_name" ]]; then
    echo "Template already exists in library"
    template_exists=true
    break
  fi
done <<< "$library_items"

if [[ "$template_exists" == false ]]; then
  echo "Importing template to library"
  curl -s -i -O ${file_url}
  govc library.import -k=true "${chosen_library}" "${file_url}"
fi
echo ${template_name} 
