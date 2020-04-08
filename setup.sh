#!/bin/bash
# -*- coding: utf-8 -*-
#
# Usage:  ./setup.sh [--option install]
# author: Calvin Low

# Initial setup manual
# aws configure
# export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
# export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)

# set -euo pipefail


declare name=kops_demo
declare ec2_type=t2.medium

function usage () { 
    echo -e "usage: $0 | --option [argument] | --help\\n" 
    echo -e "If no parameters given the script will perform NOTHING\\n" 
    echo -e "--option Defines which option you want to trigger\\n" 
    echo -e " install setup K8S cluster\\n" 
    echo -e " cleanup remove K8S cluster\\n"
    echo -e "--help Shows this usage information\\n" 
    exit 1
}

function setup_group() {
    aws iam create-group --group-name $name
    aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name $name
    aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name $name
    aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name $name
    aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name $name
    aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name $name
}

function setup_user() {
    aws iam create-user --user-name $name
    aws iam add-user-to-group --user-name $name --group-name $name
    aws iam create-access-key --user-name $name
}

function setup_s3_bucket() {
    aws s3api create-bucket --bucket devpoc.calsaviour.k8s.local --create-bucket-configuration LocationConstraint=us-west-2
    export STATE_STORE=s3://devpoc.calsaviour.k8s.local
}

function setup_ssh_key() {
    aws ec2 create-key-pair --key-name kp_devpoc_k8s | jq -r '.KeyMaterial' > kp_devpoc_k8s.pem
    mv kp_devpoc_k8s.pem ~/.ssh/ 
    chmod 400 ~/.ssh/kp_devpoc_k8s.pem
    ssh-keygen -y -f ~/.ssh/kp_devpoc_k8s.pem > ~/.ssh/kp_devpoc_k8s.pub
}


function setup_cluster() {
    export AWS_REGION=us-west-2
    export S3_NAME=devpoc.calsaviour.k8s.local
    export STATE_STORE=s3://$S3_NAME

    kops create cluster \
    --cloud aws \
    --networking kubenet \
    --name $S3_NAME \
    --master-size $ec2_type \
    --node-size $ec2_type \
    --zones us-west-2a \
    --ssh-public-key ~/.ssh/kp_devpoc_k8s.pub \
    --yes
}


function cleanup() {

    ## Delete Cluster
    kops delete cluster devpoc.calsaviour.k8s.local --yes
    
    ## Delete key-pair
    aws ec2 delete-key-pair --key-name kp_devpoc_k8s

    ## Delete User
    aws iam remove-user-from-group --user-name $name --group-name $name
    temp=$(aws iam list-access-keys --user-name $name | jq -r '.AccessKeyMetadata[0].AccessKeyId')
    aws iam delete-access-key --access-key-id $temp --user-name $name
    aws iam delete-user --user-name $name

    ## Delete group
    aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name $name
    aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name $name
    aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name $name
    aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name $name
    aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name $name
    aws iam delete-group --group-name $name

    ## Delete S3 bucket
    aws s3api delete-bucket --bucket devpoc.calsaviour.k8s.local --region us-west-2

}

# If no arguments passed, do full backup
if [[ $# -eq 0 ]] ; 
then 
    echo "No arguments given, doing NOTHING."
    usage
    OPTION_TYPE="NOTHING"
fi

### Handle arguments ##
POSITIONAL=[]
while [[ $# -gt 0 ]]
do
key="$1"
case ${key} in 
    -o|--option) 
    set +u 
    if [ ! -z $2 ] ; then 
        PARAM=$2    
    else 
        PARAM="NONE"
    fi
    set -u
    if [[ "${PARAM}" == "install" ]]; then 
        OPTION_TYPE="INSTALL"     
    elif [[ "${PARAM}" == "cleanup" ]]; then 
        OPTION_TYPE="CLEANUP" 
    else 
        echo "Not a valid parameter given for \"--option\"! Please see the instructions below" 
        usage 
    fi
    shift # past argument
    shift # past value
    ;; 
    -h|--help) 
    usage 
    shift # past argument 
    ;;
    *) 
    usage 
    shift # past argument
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ "${OPTION_TYPE}" == "INSTALL" ]]; 
then 
    echo "Starting the setup of K8S"
    setup_group
    setup_user
    setup_s3_bucket
    setup_ssh_key
    setup_cluster
    echo "Complete the setup of K8S"
fi

if [[ "${OPTION_TYPE}" == "CLEANUP" ]]; then
    echo "Cleaning up K8S"
    cleanup
    echo "Cleanup done"
fi