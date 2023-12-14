## Script for automated creation of Proxmox VM templates.

### How to use:

Script needs `secrets.auto.pkrvars.hcl` file based on `secrets-example` with filled secrets to execute propertly.

To run execute `packer build -var-file='templates/worker-node.pkrvars.hcl' .` from ubuntu directory.
