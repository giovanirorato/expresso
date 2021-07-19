#!/bin/bash
#
# Expresso - Ambiente Jupyter para seu desenvolvimento em Data Science
# 
# Repo:             https://github.com/giovanirorato/expresso
# Title:            expresso
# Author:           Giovani Rorato
# Version:          1.2.1

inicio=$(date +%s)

version_atual=1.2.1

clear

echo
echo "#########################################################################"
echo "#                                                                       #"
echo "# Expresso - Ambiente Jupyter para seu desenvolvimento em Data Science  #"
echo "#             https://github.com/giovanirorato/expresso                 #"
echo "#                                                                       #"
echo "#########################################################################"
echo

# Nome do conteiner
read -p "# Insira um nome para o seu container: [expresso] " container_name
if [ -z "$container_name" ]; then
  container_name="expresso"
fi

if [[ -z "$container_name" || -n "$(docker ps -aq -f name="$container_name")" ]]; then
  read -p "# Já existe um container com esse nome deseja excluir? [s/n] " excluir_container
  case $excluir_container in
    "")
      docker rm -f "$(docker ps -aq -f name="$container_name")" ;;
    s)
      docker rm -f "$(docker ps -aq -f name="$container_name")" ;;
    n)
      while [ -n "$(docker ps -aq -f name="$container_name")" ]; do
        read -p "# Defina um nome diferente de $container_name porque já está sendo usado: " container_name
      done
      ;;
  esac
fi

# Versão da imagem
read -p "# Insira o número de versão para sua imagem no formato: [$version_atual] " version
if [ -z "$version" ]; then
  version=$version_atual
fi

# Versão da instalação do python
read -p "# Insira a versão do python que irá usar.: [3.8.11] " python
if [ -z "$python" ]; then
  python=3.8.11
fi

read -p "# Imforme o diretório local para o Jupyter: [$(pwd)] " diretorio
if [ -z "$diretorio" ]; then
  diretorio=$(pwd)
fi

read -p "# Definina a porta do Jupyterlab: [80] " porta
if [ -z "$porta" ]; then
  porta=80
  status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost:$porta)"
    while [[ "$status_code" -eq 302 || -z "$porta" ]]; do
      porta=$(expr $porta + 1)
      read -p "# A Porta que você escolheu está em uso ou é inválida, deseja escolher outra? [$porta] " porta
      status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost:$porta)"
    done
else
  status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost:$porta)"
    while [[ "$status_code" -eq 302 || -z "$porta" ]]; do
      porta=$(expr $porta + 1)
      porta2=$porta
      read -p "# A Porta que você escolheu está em uso ou é inválida, deseja escolher outra? [$porta] " porta
      if [ -z "$porta" ]; then
        porta=$porta2
      fi
      status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost:$porta)"
    done
fi

if [ -n "$(docker ps -aq -f name=""$container_name"_base")" ]; then
  echo "# Exclui container criado anteriormente."
  docker rm -f "$(docker ps -aq -f name=""$container_name"_base")"
fi

# Exclui arquivo temporário criado anteriormente.
rm -rf "$diretorio"/"$container_name"_docker.sh

# Gerando o scrip para rodar dentro do docker.
cat << EOF > "$diretorio"/"$container_name"_docker.sh
#!/bin/bash

# Atualiza o centos para upstream
dnf -y swap centos-linux-repos centos-stream-repos
dnf -y distro-sync

## Ajuste de Timezone
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Pacotes adicionais
dnf -y install vim
dnf -y install ncurses
dnf -y install wget
dnf -y install git
dnf -y module install nodejs:14

# Requisitos do Pyenv
dnf -y install make gcc gcc-c++ zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel

# Instalação do Pyenv
curl https://pyenv.run | bash

wget -q https://raw.githubusercontent.com/giovanirorato/expresso/release_1.2.1/.bashrc -O ~/.bashrc

source ~/.bashrc

# Instalação da versão do Python escolhida
pyenv install $python

# Criando e instalando o ambiente virtual
pyenv virtualenv $python $container_name

mkdir /root/$container_name
cd /root/$container_name
pyenv local $container_name

# Upgrade do PIP
pip3 install --upgrade pip

# Instalação Limpa
pip install jupyterlab

# Instalação Completa
pip install beautifulsoup4
pip install pipreqs
pip install bokeh
pip install cx-oracle
pip install fbprophet
pip install flake8
pip install pylint
pip install keras
pip install pip-chill
pip install plotly
pip install pydot
pip install scrapy
pip install seaborn
pip install sklearn
pip install statsmodels
pip install tensorflow
pip install nbdime
pip install xgboost

# Limpeza dos arquivos de cache
dnf clean all
pip cache purge

# Metabase
dnf -y install java-11-openjdk
cd /srv
wget https://downloads.metabase.com/v0.38.0.1/metabase.jar
mkdir plugins && cd /srv/plugins
wget https://download.oracle.com/otn-pub/otn_software/jdbc/211/ojdbc11.jar
cd ..
nohup java -jar /srv/metabase.jar &

# execução do Jupyter
cd /root/$container_name
jupyter-lab --allow-root --notebook-dir='/root/$container_name' --ip='*' --no-browser --NotebookApp.token='' --NotebookApp.password=''
EOF

# Coloca o arquivo como executável.
chmod +x "$diretorio"/"$container_name"_docker.sh

echo "
# 2 opções de instalação:
  - Limpa [l]:
    - jupyterlab
  - Completa [c]:
    - beautifulsoup4    - plotly
    - bokeh             - pydot
    - cx-oracle         - pylint
    - fbprophet         - scrapy
    - flake8            - seaborn
    - keras             - sklearn
    - nbdime            - statsmodels
    - pip-chill         - tensorflow
    - pipreqs           - xgboost
"

read -p "# Selecione instalação [l] Limpa ou [c] Completa. [l|c]: " limpa_completa
if [ "$limpa_completa" = "l" ] || [ -z "$limpa_completa" ]; then
  sed -i '' -e '/# Instalação Completa/,+19d' "$diretorio"/"$container_name"_docker.sh
fi

read -p "# Quer instalar o Metabase [s/n]: " metabase
if [ "$metabase" = "n" ] || [ -z "$metabase" ]; then
  sed -i '' -e '/# Metabase/,+8d' "$diretorio"/"$container_name"_docker.sh

  echo "# Cria container "$container_name" sem Metabase."
  docker container run -d -p "$porta":8888 \
    -v "$diretorio":/root/"$container_name" \
    -v "$diretorio"/"$container_name"_docker.sh:/tmp/"$container_name"_docker.sh \
    --name "$container_name"_base centos:latest ./tmp/"$container_name"_docker.sh \
    bash -c "jupyter-lab --allow-root --notebook-dir='/root/$container_name' --ip='*' --no-browser --NotebookApp.token='' --NotebookApp.password=''"
elif [ "$metabase" = "s" ]; then
  echo "# Cria container "$container_name" com Metabase."
  docker container run -d -p "$porta":8888 -p 3000:3000 \
    -v "$diretorio":/root/"$container_name" \
    -v "$diretorio"/"$container_name"_docker.sh:/tmp/"$container_name"_docker.sh \
    --name "$container_name"_base centos:latest ./tmp/"$container_name"_docker.sh \
    bash -c "jupyter-lab --allow-root --notebook-dir='/root/$container_name' --ip='*' --no-browser --NotebookApp.token='' --NotebookApp.password=''"
fi

status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost:$porta)"

while [[ "$status_code" -ne 302 ]]; do
  printf "."
  sleep 5
  status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost:$porta)"
done

echo
echo "# Realiza o commit da nova imagem, apaga "$container_name"_base e o centos:latest."
docker commit $(docker ps -q -f name=""$container_name"_base") "$container_name":"$version" && \
docker rm -f "$container_name"_base && \
docker rmi -f centos:latest

rm -rf "$diretorio"/"$container_name"_docker.sh

if [ -n "$(docker ps -aq -f name="$container_name")" ]; then
  echo "# Exclui container criado anteriormente de mesmo nome."
  docker rm -f "$(docker ps -aq -f name="$container_name")"
fi

if [ "$metabase" = "n" ]; then
  echo "Cria o container definifivo."
  docker container run -d -p "$porta":8888 \
    -v "$diretorio":/root/"$container_name" \
    --name "$container_name" "$container_name":"$version" \
    bash -c "jupyter-lab --allow-root --notebook-dir='/root/$container_name' \
    --ip='*' --no-browser --NotebookApp.token='' --NotebookApp.password=''"
elif [ "$metabase" = "s" ]; then
  echo "Cria o conteainer definitivo com Metabase."
  docker container run -d -p "$porta":8888 -p 3000:3000 \
    -v "$diretorio":/root/"$container_name" \
    --name "$container_name" "$container_name":"$version" \
    bash -c "jupyter-lab --allow-root --notebook-dir='/root/$container_name' \
    --ip='*' --no-browser --NotebookApp.token='' --NotebookApp.password=''"
fi

# Tempo de execução.
echo "# Fim"
tempo_gasto=$(($(date +%s) - $inicio))
final=$(echo "scale=2; $tempo_gasto / 60" | bc -l)
echo "# A imagem "$container_name":"$version" demorou: $final minutos para ser compilada!"

exit
