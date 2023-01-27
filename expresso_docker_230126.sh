#!/bin/bash

clear

echo
echo "#########################################################################"
echo "#                                                                       #"
echo "# Expresso - Ambiente Jupyter para seu desenvolvimento em Data Science  #"
echo "#             https://github.com/giovanirorato/expresso                 #"
echo "#                                                                       #"
echo "#########################################################################"
echo

read -p "# Insira um nome para o seu container: [expresso] " container_name
if [ -z "$container_name" ]; then
  container_name="expresso"
fi

read -p "# Defina a porta: [8888] " porta
if [ -z "$porta" ]; then
  porta="8888"
fi

read -p "# Imforme o diretório local do Jupyter: [$(pwd)] " diretorio
if [ -z "$diretorio" ]; then
  diretorio=$(pwd)
fi

wget https://raw.githubusercontent.com/giovanirorato/expresso/main/Dockerfile

docker build --build-arg NUM_PROCESSES=$(nproc) -t $container_name .

docker run -dit -v $diretorio:/root/expresso -p $porta:8888 --name $container_name $container_name