FROM quay.io/centos/centos:stream9

# Ajuste de timezone
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Atualizações de sistema
RUN dnf -y install epel-release \
    && dnf -y update \
    && dnf install epel-release \
    && dnf -y install git vim bash-completion \
    && dnf -y install gcc make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel \
    && dnf clean all

# Instalação do Pyenv
RUN curl https://pyenv.run | bash

# Ajuste do arquivo .bashrc
RUN echo -e '\n# Pyenv\nexport PYENV_ROOT="$HOME/.pyenv"\ncommand -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"\neval "$(pyenv init -)"' >> ~/.bashrc

# Variáveis de otimização do Python
ENV CONFIGURE_OPTS="--enable-optimizations"
ENV MAKE_OPTS="-j2"
ENV CFLAGS_OPTS="-O2" 
ENV CXXFLAGS_OPTS="-O2"

RUN ls -la ~/.pyenv/

# Instalação do python
RUN ~/.pyenv/bin/pyenv install 3.11.1 \
    && ~/.pyenv/bin/pyenv virtualenv 3.11.1 expresso

WORKDIR /root/dev

RUN pyenv local expresso

RUN pip install --upgrade pip
RUN pip install jupyterlab && pip cache purge

EXPOSE 8888
CMD ["jupyter-lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]