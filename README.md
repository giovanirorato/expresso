# expresso

Começe a desenvolver os seus projetos em Data Science com o Expresso.

Ambiente criado para que você possa mergulhar no mundo do data science.

O ambiente usa o docker para criar o seu ambiente.

## Requisitos

- MacOS ou Linux
- Docker

## Para fazer criação da imagem via shell script

Abra um terminal shell e execute o comando abaixo.

<!--
Link curto

    bash <(curl -s https://url.gratis/aL32E)
-->

    bash <(curl -s https://raw.githubusercontent.com/giovanirorato/expresso/main/expresso.sh)

    bash <(curl -s https://raw.githubusercontent.com/giovanirorato/expresso/main/expresso_docker.sh)

## Comandos

    docker build -t giovanirorato/expresso .

    docker run -dit -v /Users/giovani/Documents/dev:/root/expresso -p 8888:8888 --name expresso giovanirorato/expresso
