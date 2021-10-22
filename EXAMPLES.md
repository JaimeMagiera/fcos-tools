# Examples

Here are examples of using the scripts in this repository to provision and manage FCOS nodes. They utilize the [govc](https://github.com/vmware/govmomi/tree/master/govc) command line tool through a container, which is run by Podman. As such, it's assumed that Podman is installed. Likewise, the scripts assume you've set your govc environment variables for cluster URL, username, password, etc. See the gov documentation for more details.

## Loaded the latest vSphere template available for a given FCOS stream ##
In this example, the latest release template from the FCOS *next* stream is imported into the vSphere Content Library "Linux ISOs". The script can pull the latest .ova from the stable, testing, and next streams. If the template already exists in the library, the script outputs a message and exits.
``` Bash
#!/bin/bash

manage-release-template.sh --stream "next" --library "Linux ISOs"
```

## Deploying a vm from a vSphere FCOS template with ignition and k-args
In this example, it's assumed that the template "fedora-coreos-33.20201201.3.0-vmware.x86_64" exists the vSphere Content Library "Linux ISOs"

``` Bash
#!/bin/bash

deploy-coreos-node.sh --ova fedora-coreos-33.20201201.3.0-vmware.x86_64 --ignition "fcos-next.ign" --name "fcos-next" --cpu 2 --memory 4000 --disk 100 --folder "/MyCluster/vm/Linux/FCOS/" --library "Linux ISOs" --ipcfg "ip=10.211.2.92::10.211.0.1:255.255.255.0:${VM_NAME}:${IFACE}:off" --boot
```

## Combining the template import and vm deployment scripts to automate the process of deploying the latest of a chosen FCOS stream.
This script combines the two scripts above to automate the process of downloading the latest template for a given stream and deploying a vm for that respective template.

``` Bash
#!/bin/bash

source manage-release-template.sh --stream "next" --library "Linux ISOs"
deploy-coreos-node.sh --ova "$template_name" --ignition "fcos-next.ign" --name "fcos-next" --cpu 2 --memory 4000 --disk 100 --folder "/MyCluster/vm/Linux/FCOS/" --library "Linux ISOs" --ipcfg "ip=10.211.2.92::10.211.0.1:255.255.255.0:${VM_NAME}:${IFACE}:off" --boot
```
