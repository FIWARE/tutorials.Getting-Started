#!/bin/bash
#
#	Command Line Interface to start all services associated with the Getting-Started Tutorial
#
#	For this tutorial the commands are merely a convenience script to run kubernetes
#

set -e

helm repo add bitnami_legacy https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami

kubectl apply -f ./secrets/mongodb.yaml  
helm dependency build mongodb
helm install mongodb-orion mongodb 

helm dependency build orion-ld
helm install orion-ld orion-ld 