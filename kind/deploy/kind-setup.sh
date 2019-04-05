#!/usr/bin/env bash

#set -x

################################################################################
#### Variables, Arrays, and Hashes #############################################
################################################################################

CLUSTER_CONFIG="1m1w.yaml"
CONFIG_PATH="../config"

################################################################################
#### Functions #################################################################
################################################################################

# **********************************************
# Set command name
# **********************************************
cmd() { 
    
    echo `basename $0`

}

# **********************************************
# Print script usage message
# **********************************************
usage() {

echo "\
`cmd` [OPTION...]
-c, --create; Create a KIND Cluster
-d, --delete; Delete a KIND Cluster
-n, --name NAME; The name to use for the KIND Cluster
-f, --config-file [FILE]; The config file to use for the KIND Cluster (default = \"1m1w.yaml\")
" | column -t -s ";"

}

# **********************************************
# Set command arguments
# **********************************************
set_args() {

    options=$(getopt -o :cdvn:f: --long create,delete,verbose,name:,config-file: -- "${@}")

    [ $? -eq 0 ] || {

        usage
        exit 1

    }

    eval set -- "${options}"

    while true; do

        case ${1} in
        
            -c|--create )

                    echo "Option \"create\" specified"

                    RUN_TYPE="create"

            ;;
            -d|--delete )

                    echo "Option \"delete\" specified"

                    RUN_TYPE="delete"

            ;;
            -v|--verbose )

                    echo "Option \"verbose\" specified"

                    DEBUG="echo"

            ;;
            -n|--name )

                    echo "Option \"name\" specified"

                    shift;
                    
                    CLUSTER_NAME="${1}"

            ;;
            -f|--config-file )

                    echo "Option \"config-file\" specified"

                    shift;

                    if [ "${1}" != "" ]; then
                        
                        if [ -f ${CONFIG_PATH}/${1}.yaml ]; then
                        
                            CLUSTER_CONFIG="${1}.yaml"

                        else

                            echo "Config File \"${CLUSTER_CONFIG}\" was not found in \"${CONFIG_PATH}\""
                            echo
                            usage
                            exit 1
                        
                        fi

                    else

                        echo "Config file was not specified"

                    fi

            ;;
            --)
                    shift
                    break
            ;;

        esac

        shift

    done

}

# **********************************************
# Create KIND Cluster
# **********************************************
cluster_create() {

    echo "Creating KIND Cluster \"${CLUSTER_NAME}\" using config file \"${CONFIG_PATH}/${CLUSTER_CONFIG}\""
    echo

    # Create the KIND Cluster
    kind create cluster --config ${CONFIG_PATH}/${CLUSTER_CONFIG} --name ${CLUSTER_NAME}

    # Set KUBECONFIG
    export KUBECONFIG="$(kind get kubeconfig-path --name="${CLUSTER_NAME}")"

    # Label Worker Nodes
    kubectl label nodes -l node-role.kubernetes.io/master!= node-role.kubernetes.io/worker=

    if [ "${CLUSTER_CONFIG}" == "3m3w.yaml" ]; then

        # Label Node AZ's
        for node in `kubectl get nodes -o custom-columns=NODE:.metadata.name --no-headers`; do

                # Get AZ based off node instance number
                local AZ_NUM=`kubectl get node ${node} -o custom-columns=NODE:.metadata.name --no-headers | sed 's/.*\([0-9]\)$/\1/'`

                # Label node for AZ
                kubectl label node ${node} failure-domain.beta.kubernetes.io/zone="AZ${AZ_NUM}"

        done

    fi

}

# **********************************************
# Delete KIND Cluster
# **********************************************
cluster_delete() {

    echo "Deleting KIND Cluster \"${CLUSTER_NAME}\""
    echo

    # Delete the KIND Cluster
    kind delete cluster --name ${CLUSTER_NAME}

}

################################################################################
#### Main ######################################################################
################################################################################

set_args "${@}"

case ${RUN_TYPE} in 

  create)
      cluster_create
      ;;
  delete)
      cluster_delete
      ;;
       *)
      usage
      exit 1
      ;; 

esac

