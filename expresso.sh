#!/bin/bash
inicio=$(date +%s)

clear

echo "############################################################################"
echo "#                                                                          #"
echo "#   Expresso - Ambiente Jupyter para seu desenvolvimento em Data Science   #"
echo "#                                                                          #"
echo "############################################################################"


echo -n "# Insira um nome para o seu container: "
read container_name
if [ "$container_name" = "" ]; then
  container_name="expresso"
fi


echo -n "# Insira uma versão para a sua imagem no formato [1.0.0]: "
read version
if [ "$version" = "" ]; then
  version="1.0.0"
fi


echo -n "# Imforme o diretório local para o Jupyter. [/<dir_atual>]: "
read diretorio
if [ "$diretorio" = "" ]; then
  diretorio=$(pwd)
fi


if [ -n "$(docker ps -aq -f name="$container_name")" ]; then
  echo "# Exclui imagem criada anteriormente."
  docker rm -f "$(docker ps -aq -f name="$container_name")"
fi


if [ -n "$(docker images -aq --filter=reference=""$container_name":"$version"")" ]; then
  echo -n "# Já existe uma imagem "$container_name":"$version", Quer mandar para o Docker Hub? [S/N] "
  read enviar_imagem
  if [ "$enviar_imagem." = "S." ]; then
    echo -n "# Informe seu usuário: "
    read nome_usuario
    docker push "$nome_usuario"/"$container_name":"$version"
    docker rmi -f "$(docker images -aq --filter=reference=""$nome_usuario"/"$container_name":"$version"")"
  else
    docker rmi -f "$(docker images -aq --filter=reference=""$nome_usuario"/"$container_name":"$version"")"
  fi
fi


if [ -x ""$diretorio"/"$container_name"_docker.sh" ]; then
  echo "# Removendo arquivo anterior."
  rm "$diretorio"/"$container_name"_docker.sh
fi


echo "# Gerando o scrip para rodar dentro do docker."
cat << EOF > "$diretorio"/"$container_name"_docker.sh
#!/bin/bash

# Atualiza o centos para upstream
dnf -y swap centos-linux-repos centos-stream-repos
dnf -y distro-sync

# Instalação de bibliotecas C e C++
dnf -y install gcc
dnf -y install gcc-c++

# Instalação do python3.8.6
dnf -y install python38
dnf -y install python38-devel

# Pacotes adicionais
dnf -y install vim
dnf -y install ncurses
dnf -y install sqlite
dnf -y install wget

# Upgrade do PIP
pip3 install --upgrade pip

# Instalação de pacotes PIP
pip install cx-oracle
pip install fbprophet
pip install flake8
pip install jupyterlab
pip install keras
pip install pip-chill
pip install plotly
pip install seaborn
pip install sklearn
pip install statsmodels
pip install tensorflow

# metabase
dnf -y install java-11-openjdk
cd /srv
wget https://downloads.metabase.com/v0.38.0.1/metabase.jar
mkdir plugins && cd /srv/plugins
wget https://download.oracle.com/otn-pub/otn_software/jdbc/211/ojdbc11.jar
cd ..
nohup java -jar /srv/metabase.jar &

# Limpeza dos arquivos de cache
dnf clean all
pip cache purge

# execução do Jupyter
jupyter-lab --allow-root --notebook-dir='/root/$container_name' --ip='*' --no-browser --NotebookApp.token='' --NotebookApp.password=''

EOF


echo "# Coloca o arquivo como executável."
chmod +x "$diretorio"/"$container_name"_docker.sh


echo -n "# Gostaria de instalar o Metabase? [S/N]: "
read Metabase
if test $% = 0
then
  echo Faltou informar a resposta.
  exit 1
fi


echo "# Gerando o scrip para rodar dentro do docker."
if test "$Metabase" = N
then
  sed -n '37,45d' "$diretorio"/"$container_name"_docker.sh
  
  echo "# Cria container "$container_name" sem Metabase."
  docker container run -d -p 80:8888 \
    -v "$diretorio":/root/"$container_name" \
    -v "$diretorio"/"$container_name"_docker.sh:/tmp/"$container_name"/"$container_name"_docker.sh \
    --name "$container_name" centos:latest ./tmp/"$container_name"/"$container_name"_docker.sh
elif test "$Metabase" = S
then
  echo "# Cria container "$container_name" com Metabase."
  docker container run -d -p 80:8888 -p 3000:3000 \
    -v "$diretorio":/root/"$container_name" \
    -v "$diretorio"/"$container_name"_docker.sh:/tmp/"$container_name"/"$container_name"_docker.sh \
    --name "$container_name" centos:latest ./tmp/"$container_name"/"$container_name"_docker.sh
fi


status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost)"

while [[ "$status_code" -ne 302 ]];
do
  # echo "Executa o comando "$status_code""
  printf "."
  sleep 5
  status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost)"
done


echo -e "\n"
echo -n "# Vamos criar uma imagem do "$container_name":"$version" [S/N]: " 
read criar_imagem
if [ "$criar_imagem" = "S." ]
then
docker commit "$(docker ps -q -f name="$container_name") "$container_name":"$version""
fi

echo -n "# Quer enviar a imagem para o Docker Hub? Lembre-se de se logar antes. [S/N] "
read docker_hub
if [ "$docker_hub." = "S." ]; then
  echo -n # Coloque o nome do seu usuário: "
  read nome_usuario
  docker push "$nome_usuario"/"$container_name":"$version"
fi

echo "# calculando o tempo gasto"
tempogasto=$(($(date +%s) - $inicio))
final=$(echo "scale=2; $tempogasto / 60" | bc -l)
echo "# A imagem giovanirorato/"$container_name":"$version" demorou: $final minutos para ser compilada!"

exit
