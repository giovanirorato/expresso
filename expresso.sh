#!/bin/bash
#
# Expresso - Ambiente Jupyter para seu desenvolvimento em Data Science

inicio=$(date +%s)

clear

echo
echo "###########################################################################"
echo "#                                                                         #"
echo "#  Expresso - Ambiente Jupyter para seu desenvolvimento em Data Science   #"
echo "#             https://github.com/giovanirorato/expresso                   #"
echo "#                                                                         #"
echo "###########################################################################"
echo

# if [ -n "$(docker ps -aq -f name="$container_name")" ]; then
#   echo "# Exclui container criado anteriormente."
#   docker rm -f "$(docker ps -aq -f name="$container_name")"
# fi

if [ -n "$(docker ps -aq -f name="$container_name")" ]; then
  read -p "# Já existe um container com esse nome deseja excluir? [s|n] " excluir_container
  elif [[ -z "$excluir_container" || "$excluir_container" -eq "s" ]]; then
    docker rm -f "$(docker ps -aq -f name="$container_name")"
  else
    read -p "# Defina um novo nome. [expresso] " container_name
      while  []
fi


read -p "# Insira um nome para o seu container: [expresso] " container_name
if [ -z "$container_name" ]; then
  container_name="expresso"
  elif [ -n "$(docker ps -aq -f name="$container_name")" ]; then
    read -p "# Já existe um container com esse nome deseja excluir? [s|n] " excluir_container
    elif [[ -z "$excluir_container" || "$excluir_container" -eq "s" ]]; then
      docker rm -f "$(docker ps -aq -f name="$container_name")"
    else
      read -p "# Defina um novo nome. [expresso] " container_name
fi

exit

read -p "# Insira o número de versão para sua imagem no formato: [1.0.0] " version
if [ -z "$version" ]; then
  version="1.0.0"
fi

read -p "# Imforme o diretório local para o Jupyter: [$(pwd)] " diretorio
if [ -z "$diretorio" ]; then
  diretorio=$(pwd)
fi

read -p "# Definina a porta do Jupyterlab: [80] " porta
if [ -z "$porta" ]; then
  porta=80
  status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost:$porta)"
    while [[ "$status_code" -eq 302 || "$porta" -eq 0 ]]; do
      porta=$(expr $porta + 1)
      read -p "# A Porta que você escolheu está em uso ou é inválida, deseja escolher outra? [$porta] " porta
      status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost:$porta)" 
    done
else
  status_code="$(curl --write-out %{http_code} --silent --output /dev/null localhost:$porta)"
    while [[ "$status_code" -eq 302 || "$porta" -eq 0 ]]; do
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

if [ -n "$(docker images -aq --filter=reference="$container_name:$version")" ]; then
  read -p "# Já existe uma imagem "$container_name":"$version", Quer mandar para o Docker Hub? [s/n] " enviar_imagem
  if [ "$enviar_imagem" = "s" ];   then
    read -p "# Informe seu usuário: " nome_usuario
    docker push "$nome_usuario"/"$container_name":"$version"
    if [ -n "$(docker ps -aq -f name="$container_name")" ]; then
      echo "# Exclui container criado anteriormente."
      docker rm -f "$(docker ps -aq -f name="$container_name")"
    fi
    docker rmi -f "$(docker images -aq --filter=reference=""$nome_usuario"/"$container_name":"$version"")"
  else
    echo "Excluindo imagem de mesmo nome criado anteriormente."
    if [ -n "$(docker ps -aq -f name="$container_name")" ]; then
      echo "# Exclui container criado anteriormente."
      docker rm -f "$(docker ps -aq -f name="$container_name")"
    fi
    docker rmi -f "$( docker images -aq --filter=reference=""$nome_usuario"/"$container_name":"$version"" | docker images -aq --filter=reference=""$container_name":"$version"" )"
  fi
fi

# Exclui arquivo temporário criado anteriormente.
rm -rf "$diretorio"/"$container_name"_docker.sh

# Gerando o scrip para rodar dentro do docker.
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
dnf -y install git
dnf -y module install nodejs:14

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
  echo "# Exclui container criado anteriormente."
  docker rm -f "$(docker ps -aq -f name="$container_name")"
fi

if [ "$metabase" = "n" ]; then
  echo "Cria o container definifivo."
  docker container run -d -p "$porta":8888 \
    -v "$diretorio":/root/"$container_name" \
    --name "$container_name" "$container_name":"$version" \
    bash -c "jupyter-lab --allow-root --notebook-dir='/root/$container_name' --ip='*' --no-browser --NotebookApp.token='' --NotebookApp.password=''"
elif [ "$metabase" = "s" ]; then
  echo "Cria o conteainer definitivo com Metabase."
  docker container run -d -p "$porta":8888 -p 3000:3000 \
    -v "$diretorio":/root/"$container_name" \
    --name "$container_name" "$container_name":"$version" \
    bash -c "jupyter-lab --allow-root --notebook-dir='/root/$container_name' --ip='*' --no-browser --NotebookApp.token='' --NotebookApp.password=''"
fi

read -p "# Quer enviar a imagem para o Docker Hub? Lembre-se de se logar antes [s/n]: " docker_hub
if [ "$docker_hub" = "s" ]; then
  read -p "# Coloque o nome do seu usuário Docker Hub: " nome_usuario
  docker push "$nome_usuario"/"$container_name":"$version"
fi

# Tempo de execução.
echo "# Fim"
tempo_gasto=$(($(date +%s) - $inicio))
final=$(echo "scale=2; $tempo_gasto / 60" | bc -l)
echo "# A imagem "$container_name":"$version" demorou: $final minutos para ser compilada!"

exit
