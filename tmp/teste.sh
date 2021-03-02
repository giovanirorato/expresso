if [ -n $(docker images -aq --filter=reference="giovanirorato/expresso:$VERSION") ];
then
  echo "jä existe uma imagem com essa versão, Quer enviar a imagem para o Docker Hub ou excluir? (S/E)"
  read resp
  if [ $resp. = 'S.' ];
  then
    # docker push giovanirorato/expresso:$VERSION
    echo "Envia imagem para o docker hub"
  else
    if [ $resp. = 'E.' ];
    then
      # docker rmi -f $(docker images -aq --filter=reference="giovanirorato/expresso:$VERSION")
      echo "Remove a imagem"
    fi
  fi
fi
