FROM quay.io/centos/centos:stream9

# Adjust timezone
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Number os process
ARG container_name=expresso
ENV LATEST_PYTHON_VERSION=3.11.1
RUN NUM_PROCESSES="$(nproc)"

# Variables and Workdir
ENV HOME="/root"
WORKDIR ${HOME}/${container_name}
ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

# Update system
RUN dnf -y update \
    && dnf -y install git vim bash-completion wget \
    && dnf -y install gcc make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel \
    && dnf clean all

# Install
RUN curl https://pyenv.run | bash

# Update .bashrc
RUN echo -e "\n# Pyenv" >> ~/.bashrc
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
RUN echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc
RUN exec "$SHELL"

# Optimization for Python
ENV CONFIGURE_OPTS="--enable-optimizations"
ENV MAKE_OPTS "-j$NUM_PROCESSES"
ENV CFLAGS_OPTS="-O2" 
ENV CXXFLAGS_OPTS="-O2"

# Install Python
RUN pyenv update
RUN pyenv install $LATEST_PYTHON_VERSION

RUN pyenv virtualenv $LATEST_PYTHON_VERSION ${container_name}

# Set virtualenv
RUN pyenv global ${container_name}

# Update pip and install jupyterlab
RUN pip install -U pip
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN pyenv global system && pyenv local ${container_name}

# Expose port and launch JupyterLab
EXPOSE 8888
CMD ["jupyter-lab", "--allow-root", "--ip=0.0.0.0", "--no-browser"]