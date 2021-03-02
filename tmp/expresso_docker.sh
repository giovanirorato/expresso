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

