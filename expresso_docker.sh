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

curl -o Dockerfile https://raw.githubusercontent.com/giovanirorato/expresso/main/Dockerfile

docker build -t --build-arg container=$container_name -t $container_name . \
&& docker run -dit -v $diretorio:/root/$container_name -p $porta:8888 --name $container_name $container_name