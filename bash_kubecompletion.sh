##
## Source this directly from the repo or copy local
##

export SMD="/opt/sightmachine"

##
alias ma-byobu='docker-compose exec ma script -c "byobu"'
alias ce='chef exec'

## Usage:
##     elk-kube "slice AND dice"
##
function elk-kube() {
  elktail --url http://elk.int.sightmachine.com:80 -i "logstash-[0-9].*" -f "%@timestamp %host %process %level %message" $@
}

##
##
## Methods around shared or ops Chef data bag
## Usage:
##    edit-shared-databag 20170411
##    edit-ma-config-databag uit1-gehendersonville
function _shared-databag-helper() {
  _action=$1; _item=$2; shift 2
  knife data bag ${_action} shared ${_item} --encrypt --secret-file ~/.chef/shared_data_bag_secret $@
}

function _ma-config-databag-helper() {
  _action=$1; _item=$2; shift 2
  knife data bag ${_action} ma-config ${_item} --encrypt --secret-file ~/.chef/encrypted_data_bag_secret $@
}

function show-shared-databag() {
  _shared-databag-helper show $@
}

function show-ma-config-databag() {
  _ma-config-databag-helper show $@
}

function edit-shared-databag() {
  _shared-databag-helper edit $@
}

function edit-ma-config-databag() {
  _ma-config-databag-helper edit $@
}

##
## Terraform related helpers
##
function t-plan() {
  \terraform plan -out current.plan
}

function t-apply() {
  echo "Applying plan stored in current.plan..."
  sleep 7
  if [[ -e current.plan ]]; then
    \terraform apply current.plan
  else
    echo "Unable to find current.plan... Run 't-plan' or 'terraform plan' -out current.plan"
  fi
}

function t-show() {
  \terraform show
}

##
## Git aliases
##
alias git-ma="git -C /opt/sightmachine/ma"
alias git-ma-config="git -C /opt/sightmachine/ma-sd-config"
alias git-fe-react="git -C /opt/sightmachine/fe-react"

##
## Chef exec alias
##
alias knife="chef exec knife"
alias kitchen="chef exec kitchen"
alias berks="chef exec berks"

##
## Kube
##
alias current="kubectl config current-context"
alias use-minikube="kubectl config use-context minikube"
alias use-uw1a-gcp="kubectl config use-context k8s-uw1a-gcp"
alias use-uw1c-gcp="kubectl config use-context k8s-uw1c-gcp"
alias use-dev-uw1-gcp="kubectl config use-context dev-k8s-uw1a-gcp"
alias use-dev-k8s-ue2-azure="kubectl config use-context dev-k8s-ue2-azure"
alias use-inf-uw1c-gcp="kubectl config use-context inf-k8s-uw1c-gcp"

alias kctl="k"

function check_ns_param() {
  if [[ -z "$1" ]]; then
    echo "Please pass namespace or run 'ns <namespace>' to set current namespace"
    return 1
  fi
  printf "Using namespace: ${1}\n\n"
  return 0
}


function k() {
  kubectl $@
}

function configmaps() {
  kubectl get configmaps $@
}

function delete() {
  echo "Namespace: ${KUBE_NS}, Deleting pod(s): '$@'"
  sleep 3
  kubectl delete pod $@
}

function deploys() {
  kubectl get deployments $@
}

function describe() {
  kubectl describe $@
}

function kexec() {
  kubectl exec -ti $@
}

function kmongo() {
  kexec $(kubectl get pods | grep mongo | cut -d' ' -f 1) mongo
}

function krabbit() {
	kubectl port-forward rabbitmq-0 15672
}
function kmongobash() {
  kexec $(kubectl get pods | grep mongo | cut -d' ' -f 1) bash 
}

function kpostgres() {
  kexec $(kubectl get pods | grep postgres | cut -d' ' -f 1) psql tenant_storage
}

function kpsql() {
  kpostgres
}

function logs() {
  kubectl logs $@
}

function ings() {
  kubectl get ing $@
}

function pods() {
  kubectl get pods $@
}

function secrets() {
  kubectl get secrets $@
}

function services() {
  kubectl get services $@
}

function statefulsets() {
  kubectl get statefulsets $@
}


function context() {
  kubectl config current-context
}

function help() {
  printf "\nSight Machine Dotfiles Help\n\n"
  printf "General Helpers:\n"
  echo "  ns [namespace]      --> Set, or show current, kubernetes namespace for kube helpers (this just sets KUBE_NS)"
  echo "  k <args>            --> Run kubectl with namespace set above"
  echo "  context             --> Get current kubectl context"
  echo "  configmaps [args]   --> Get all configmaps in a namespace"
  echo "  deploys [args]      --> Get all deploys in namespace"

  echo "  ings [args]         --> Get all ingresses in namespace"
  echo "  pods [args]         --> Get all pods in namespace"
  echo "  secrets [args]      --> Get all secrets in a namespace"
  echo "  statefulsets [args] --> Get all statefulsets in a namespace"
  echo "  services [args]     --> Get all services in a namespace"
  printf "\nPod Specific Helpers:\n"
  echo "  delete <pod> [args]          --> Delete a pod"
  echo "  describe <resource> [args]   --> Describe a pod"
  echo "  logs <pod> [args]            --> Logs for pod"
  echo "  kexec <pod> <command>        --> Exec into a pod"
  echo "  kmongo                       --> Mongo shell"
  echo "  kpostgres                    --> Postgres shell"
  printf "\nFor any questions see #kubernetes or #devops on Slack\n"
}


function ktx() {
    if [ -z ${1+x} ]; #check if argument passed
    then kubectl config get-contexts | grep \* | awk '{print "cluster:\n" $2 "\n\nnamespace:\n" $5}'; #if no argument print current context and namespace
    else kubectl config set-context $(kubectl config current-context) --namespace=$1; #set context and default namespace
    fi
}


function kjupyter() {
  kubectl port-forward $(kubectl get pods -l app=ma,component=notebook -o jsonpath='{.items[0].metadata.name}' | grep notebook ) 8889:8888
}

function kbash() {
	kexec $(kubectl get pods -l app=ma,component=webapp -o jsonpath='{.items[0].metadata.name}' | grep webapp ) -- bash
}

function notebash() {
	kexec $(kubectl get pods -l app=ma,component=notebook -o jsonpath='{.items[0].metadata.name}' | grep notebook) -- bash
}

function kmetaimport() {
	kexec $(kubectl get pods | grep importexport | awk '{ print $1} ') -- ma meta import
}
