FROM quay.io/centos/centos:stream9

# Adjust timezone
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Number os process
ARG container=expresso
RUN NUM_PROCESSES="$(nproc)" && \
    echo "Number of processors: $NUM_PROCESSES"

# Variables and Workdir
ENV HOME="/root"
WORKDIR ${HOME}/${container}
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
ENV LATEST_PYTHON_VERSION=$(pyenv install --list | grep -E "^\s*[0-9]+\.[0-9]+\.[0-9]+$" | tail -n 1)
RUN pyenv install $LATEST_PYTHON_VERSION

RUN pyenv virtualenv $LATEST_PYTHON_VERSION ${container}

# Set virtualenv
RUN pyenv global ${container}

# Update pip and install jupyterlab
RUN pip install -U pip
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN pyenv global system && pyenv local ${container}

# Expose port and launch JupyterLab
EXPOSE 8888
CMD ["jupyter-lab", "--allow-root", "--ip=0.0.0.0", "--no-browser"]