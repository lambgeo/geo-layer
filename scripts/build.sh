#!/bin/bash

GDAL_VERSION=$1
RUNTIME=$2

# Base Image
docker build \
    --build-arg VERSION=${GDAL_VERSION} \
    --build-arg RUNTIME=${RUNTIME} \
    -t lambgeo/lambda-gdal:${GDAL_VERSION}-${RUNTIME}-geo .
