# KIND Deploy

This directory contains KIND configs and a deploy script to provision Kubernetes clusters that are compatible with the associated Demos.

## KIND Profiles

There are 2 KIND configs included in this repo:

- [1m1w](./config/1m1w.yaml) - Includes 1 Master node and 1 Worker Node

- [3m3w](./config/3m3w.yaml) - Includes 1 Load Balancer node, 3 Master nodes, 3 Worker nodes

## Deployment

Please reference the [KIND documentation](https://kind.sigs.k8s.io/docs/user/quick-start/) for prerequisities and installation of KIND

Once you have KIND installed you can deploy clusters using the [deploy script](./deploy/kind-setup.sh) in this repo

NOTE: This script isn't super smart.....it assumes the directory structure as-is. It should be executed from the directory it lives in

### Script Usage

```
kind-setup.sh [OPTION...]
-c, --create                Create a KIND Cluster
-d, --delete                Delete a KIND Cluster
-n, --name NAME             The name to use for the KIND Cluster
-f, --config-file [FILE]    The config file to use for the KIND Cluster (default = "1m1w.yaml")
```

### Using Default Config

The `1m1w.yaml` config is used by default when the `--config-file` option is not set

```
$ cd ./deploy
$ ./kind-setup.sh --create --name <cluster_name>
```

### Specifying a Config

```
$ ./kind-setup.sh --create --name <cluster_name> --config-file <config>
```

### Working Example

```
$ ./kind-setup.sh --create --name cluster1 --config-file 3m3w
```

NOTE: You should leave the `.yaml` off of the config name, the script will take care of it

## Cleanup

You can use the same script to delete clusters when you're finished

```
$ ./kind-setup.sh --delete --name <cluster_name>
```