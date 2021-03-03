#!/bin/bash
inicio=$(date +%s)

clear

VERSION=$1

echo "# Exclui se já tiver um conteiner criado anteriormente."
if [ -n "$(docker ps -aq -f name=expresso)" ]; then
  docker rm -f "$(docker ps -aq -f name=expresso)"
fi

if [ -n "$(docker images -aq --filter=reference="giovanirorato/expresso:"$VERSION"")" ]; then
  echo "# Jä existe uma imagem expresso:"$VERSION", Quer enviar a imagem para o Docker Hub? (S/N)"
  read resp
  if [ "$resp." = "S." ]; then
    docker push giovanirorato/expresso:"$VERSION"
    docker rmi -f "$(docker images -aq --filter=reference="giovanirorato/expresso:"$VERSION"")"
  else
    docker rmi -f "$(docker images -aq --filter=reference="giovanirorato/expresso:"$VERSION"")"
  fi
fi

echo "# Remove arquivo temporario."
if [ -x "expresso_docker.sh" ]; then
  rm ./expresso_docker.sh
fi

echo "# Gerando o scrip para rodar dentro do docker."
cat <<EOF >>expresso_docker.sh
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
jupyter-lab --allow-root --notebook-dir='/root/expresso' --ip='*' --no-browser --NotebookApp.token='' --NotebookApp.password=''

EOF

echo "# Coloca o arquivo como executável."
chmod +x expresso_docker.sh


echo "# Gostaria de instalar o Metabase? (S/N)"
read Metabase
if test $% = 0
then
  echo Faltou informar a resposta.
  exit 1
fi


echo "# Gerando o scrip para rodar dentro do docker."
if test "$Metabase" = N
then

sed -n '37,45d' expresso_docker.sh

echo "# Cria container expresso sem Metabase."
docker container run -d -p 80:8888 -v /Users/giovani/Documents/dev:/root/expresso \
  -v /Users/giovani/Documents/dev/expresso/expresso_docker.sh:/tmp/expresso/expresso_docker.sh \
  --name expresso centos:latest ./tmp/expresso/expresso_docker.sh
elif test "$Metabase" = S
then
echo "# Cria conteiner expresso com Metabase."
docker container run -d -p 80:8888  -p 3000:3000 -v /Users/giovani/Documents/dev:/root/expresso \
  -v /Users/giovani/Documents/dev/expresso/expresso_docker.sh:/tmp/expresso/expresso_docker.sh \
  --name expresso centos:latest ./tmp/expresso/expresso_docker.sh
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
echo "# Cria a imagem do expresso."

docker commit "$(docker ps -q -f name=expresso) giovanirorato/expresso:"$VERSION""

echo "# Quer enviar a imagem para o Docker Hub? (S/N)"
read resp
if [ "$resp." = "S." ]; then
  docker push giovanirorato/expresso:"$VERSION"
fi

#calculando o tempo gasto
tempogasto=$(($(date +%s) - $inicio))
final=$(echo "scale=2; $tempogasto / 60" | bc -l)
echo "# A imagem giovanirorato/expresso:"$VERSION" demorou: $final minutos para ser compilada!"

exit
