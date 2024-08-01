#!/bin/bash
#
#	Command Line Interface to start all services associated with the Getting-Started Tutorial
#
#	For this tutorial the commands are merely a convenience script to run kubernetes
#

set -e

helm uninstall mongodb-orion
helm uninstall orion-ld orion-ld 