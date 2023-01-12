FROM python:3.11.1-slim

WORKDIR ~/dev

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        libzmq3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN pip install jupyterlab

EXPOSE 8888
CMD ["jupyter-lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]