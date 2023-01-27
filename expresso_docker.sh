
You can use the -n option with the read command to set a default value for the input, this way you can avoid using the if statement.

You can use the -f option with the read command to disable the automatic printing of the prompt, this way you can make the script more elegant.

#!/bin/bash

clear -q

echo
echo "#########################################################################"
echo "#                                                                       #"
echo "# Expresso - Ambiente Jupyter para seu desenvolvimento em Data Science  #"
echo "#             https://github.com/giovanirorato/expresso                 #"
echo "#                                                                       #"
echo "#########################################################################"
echo

echo -n "# Insira um nome para o seu container: [expresso] "
read -e -n container_name -i "expresso"

echo -n "# Defina a porta: [8888] "
read -e -n porta -i "8888"

echo -n "# Imforme o diretório local do Jupyter: [$(pwd)] "
read -e -n diretorio -i "$(pwd)"

curl -o Dockerfile https://raw.githubusercontent.com/giovanirorato/expresso/main/Dockerfile

exit

docker build -build-arg NUM_PROCESSES=$(nproc) -t $container_name .

docker run -dit -v $diretorio:/root/expresso -p $porta:8888 --name $container_name $container_name