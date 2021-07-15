#!/bin/bash

# Atualiza o centos para upstream
dnf -y swap centos-linux-repos centos-stream-repos
dnf -y distro-sync

## Ajuste de Timezone
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Requisitos do Pyenv
dnf -y install make gcc gcc-c++ zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel

# Instalação do Pyenv
curl https://pyenv.run | bash && pyenv install 3.8.11 && pyenv virtualenv 3.8.11 expresso

exit

cat << EOF >> ~/.bashrc
# Pyenv
export PYENV_ROOT="/Users/giovani/.pyenv"
export PATH="/Users/giovani/.pyenv/bin:/Users/giovani/.pyenv/plugins/pyenv-virtualenv/shims:/Users/giovani/.pyenv/shims:/Users/giovani/.pyenv/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
eval "export PATH="/Users/giovani/.pyenv/shims:${PATH}""
eval "export PYENV_SHELL=bash
source '/Users/giovani/.pyenv/libexec/../completions/pyenv.bash'
command pyenv rehash 2>/dev/null
pyenv() {
  local command
  command="${1:-}"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  activate|deactivate|rehash|shell)
    eval "$(pyenv "sh-$command" "$@")"
    ;;
  *)
    command pyenv "$command" "$@"
    ;;
  esac
}"
eval "export PATH="/Users/giovani/.pyenv/plugins/pyenv-virtualenv/shims:${PATH}";
export PYENV_VIRTUALENV_INIT=1;
_pyenv_virtualenv_hook() {
  local ret=$?
  if [ -n "$VIRTUAL_ENV" ]; then
    eval "$(pyenv sh-activate --quiet || pyenv sh-deactivate --quiet || true)" || true
  else
    eval "$(pyenv sh-activate --quiet || true)" || true
  fi
  return $ret
};
typeset -g -a precmd_functions
if [[ -z $precmd_functions[(r)_pyenv_virtualenv_hook] ]]; then
  precmd_functions=(_pyenv_virtualenv_hook $precmd_functions);
fi"
EOM

source ~/.bashrc

# Instalação da versão do Python escolhida
# pyenv install 3.8.11

# Criando e instalando o ambiente virtual
# pyenv virtualenv 3.8.11 expresso

cd /root/expresso
pyenv local expresso

# Pacotes adicionais
dnf -y install vim
dnf -y install ncurses
dnf -y install wget
dnf -y install git
dnf -y module install nodejs:14

# Upgrade do PIP
pip3 install --upgrade pip

# Instalação Limpa
pip install jupyterlab

# Limpeza dos arquivos de cache
dnf clean all
pip cache purge

# execução do Jupyter
jupyter-lab --allow-root --notebook-dir='/root/expresso' --ip='*' --no-browser --NotebookApp.token='' --NotebookApp.password=''
