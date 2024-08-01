#!/bin/bash
#
#	Command Line Interface to start all services associated with the Getting-Started Tutorial
#
#	For this tutorial the commands are merely a convenience script to run kubernetes
#

set -e

# Load Helm Charts
helm repo add bitnami_legacy https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami | true
helm repo add fiware https://fiware.github.io/helm-charts | true
helm repo add bitnami https://charts.bitnami.com/bitnami | true

## Install Mongo DB
kubectl apply -f ./secrets/mongodb.yaml  
helm dependency build mongodb
helm install mongodb-orion mongodb 

# Install Orion-LD
helm dependency build orion-ld
helm install orion-ld orion-ld 