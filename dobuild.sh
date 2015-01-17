#!/bin/bash
TODAY=`date +%Y-%m-%d-%H-%M`
mkdir -p out || true
rm -rf out/*
docker run -i --name="nginx_build"  askholme/buildmachine -v compile.sh:/compile.sh -v out/:/out /compile.sh
docker rm nginx_build || true