FROM quay.io/centos/centos:stream9

# Adjust timezone
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Variables and Workdir
ENV HOME="/root"
WORKDIR ${HOME}/expresso
ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

# Update system
RUN dnf -y update \
    && dnf -y install git vim bash-completion \
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
ENV MAKE_OPTS="-j2"
ENV CFLAGS_OPTS="-O2" 
ENV CXXFLAGS_OPTS="-O2"

# Install Python
RUN pyenv update
RUN pyenv install 3.11.1
RUN pyenv virtualenv 3.11.1 expresso

# Set virtualenv
RUN pyenv global expresso

# Update pip and install jupyterlab
RUN pip install -U pip
RUN pip install jupyterlab

# Expose port and launch JupyterLab
EXPOSE 8888
CMD ["jupyter-lab", "--allow-root", "--ip=0.0.0.0", "--no-browser"]