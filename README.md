# bitbucket-server

> Imagem Docker para **Servidor Bitbucket** usando Alpine Linux 
> e **Java 8** - JDK da Oracle. O alpine é uma das menores 
> distribuições linux existentes (menos de 6 Megabytes). Este 
> Projeto adiciona ao AlpineLinux uma glibc-2.21 o Java e a
> versão trial do Stash da Atlassian. Este Dockerfile foi baseado
> na versão do Anastas Dancha <anapsix@random.io> disponível no [Github](https://raw.githubusercontent.com/anapsix/docker-alpine-java/master/8/jdk/Dockerfile)
> e também usei informações [deste repositório](https://bitbucket.org/atlassian/docker-atlassian-stash/src)

Este projeto foi testado com a **versão 1.8.2** do Docker

Usado no curso [http://joao-parana.com.br/blog/curso-docker/](http://joao-parana.com.br/blog/curso-docker/) criado para a Escola Linux.

Este Contêiner espera que exista um SGBD externo em outro contêiner, 
Virtual Machine ou `bare metal server`

Faça o download do Bitbucket server

    https://www.atlassian.com/software/bitbucket/download

Escolha TAR.GZ achive

Ou usando o `curl` no terminal.

    curl -O curl -O https://downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-4.0.2.tar.gz

Criando a imagem

    docker build -t HUB-USER-NAME/bitbucket-server .

Substitua o token `HUB-USER-NAME` pelo seu login em [http://hub.docker.com](http://hub.docker.com)

Usaremos aqui o nome `java_min` para o Contêiner.
Caso exista algum conteiner com o mesmo nome rodando, 
podemos pará-lo assim:

    docker stop java_min

> Pode demorar alguns segundos para parar e isto é normal.

Em seguida podemos removê-lo

    docker rm java_min

Podemos executar o Contêiner iterativamente para verificar o Dockerfile assim:

    docker run --rm -i -t --name java_min HUB-USER-NAME/bitbucket-server 

Podemos tambem executar iterativamente assim:

    docker run --rm -i -t --name java_min \
           -p 7990:7990                       \
           HUB-USER-NAME/bitbucket-server \
           java -version

Ou preferencialmente no modo Daemon assim:

    docker run -d --name java_min         \
           -p 7990:7990                       \
           HUB-USER-NAME/bitbucket-server

Neste caso podemos verificar o Log

    docker logs java_min


No MAC OSX e Windows criamos docker-ip que é uma função no `.bash_profile` por conveniência. 
Veja o fonte abaixo:

    docker-ip() {
      boot2docker ip 2> /dev/null
    }

Após executar o sistema por um tempo, podemos parar o contêiner 
novamente para manutenção

    docker stop java_min

e depois iniciá-lo novamente e observar o log

    docker start java_min && sleep 10 && docker logs java_min

Observe que **o LOG é acumulativo**. 

Você poderá ver o conteúdo do diretório /tmp executando o comando abaixo:

    docker exec java_min ls -lat /tmp

Se você estiver usando o **MAC OSX** com Boot2Docker 
poderá executar o comando abaixo para abrir uma sessão como 
root no MySQL:

    open http://$(docker-ip):7990

No Linux (Ubuntu por exemplo) use assim:

    open http://localhost:7990

A senha do Admin do Stash está Hard-coded no arquivo de configuração, 
mas apenas por motivos didáticos. Não esqueça de alterá-la em seu ambiente
e não publique no seu repositório GIT.

## Diretórios importantes:

    Documentos do site - /var/stash/site
    Logs do Apache     - /var/log/java

Exemplo de uso do comando `docker exec` para ver o Log do Stash

    docker exec java_min cat /var/log/stash.log

Da mesma forma, para verificar a configuração do Java use:

    docker exec java_min cat /usr/local/etc/java/...


## Testando o ambiente

Para testar navegue pelo site, crie repositórios, usuários e façao git pull, commit, push, etc. 

#### Mais detalhes sobre Docker no meu Blog: [http://joao-parana.com.br/blog/](http://joao-parana.com.br/blog/)

