#!/usr/bin/env bash

set -e

IMAGE=$(readlink -f ./result)

nixgraph --depth=99 $IMAGE

feh graph.png
