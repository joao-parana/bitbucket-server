FROM alpine:3.2
#
# alpine é uma das menores distribuições linux existentes (menos de 6 Megabytes)
# Este Dockerfile adiciona ao AlpineLinux uma glibc-2.21 e o Java 8 JDK da Oracle
# Neste ambiente instalamos o Stash da Atlassian
# Este Dockerfile foi baseado na versão do Anastas Dancha <anapsix@random.io>
# disponível no [Github](https://raw.githubusercontent.com/anapsix/docker-alpine-java/master/8/jdk/Dockerfile)
# Também usei informações [deste repositório](https://bitbucket.org/atlassian/docker-atlassian-stash/src)

MAINTAINER João Antonio Ferreira "joao.parana@gmail.com"

ENV REFRESHED_AT 2015-10-03

# Install cURL
RUN apk upgrade --update && \
    apk add curl ca-certificates tar bash && \
    curl -Ls https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk && \
    apk add --allow-untrusted /tmp/glibc-2.21-r2.apk

# Versão do Java
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 60
ENV JAVA_VERSION_BUILD 27
ENV JAVA_PACKAGE       jdk

# Download e Descompactação do Java
RUN mkdir /opt && curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie"\
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
    | tar -xzf - -C /opt &&\
    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk &&\
    rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so

# Configurando variáveis de ambiente essenciais
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

# Adicionando Cliente MySQL
RUN apk add --update mysql-client && rm -rf /var/cache/apk/*

RUN apk --update add git tar bash gzip
# RUN apk --update add gzip
# 

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
ENV RUN_USER            daemon
ENV RUN_GROUP           daemon
# Install Atlassian Stash to the following location
ENV STASH_INSTALL_DIR   /opt/atlassian/stash

### ENV DOWNLOAD_URL https://downloads.atlassian.com/software/stash/downloads/atlassian-stash-

###    && curl -L --silent ${DOWNLOAD_URL}${STASH_VERSION}.tar.gz | \
###       tar -xz --strip=1 -C "$STASH_INSTALL_DIR" \

COPY atlassian-bitbucket-4.0.2.tar.gz /atlassian-bitbucket-4.0.2.tar.gz

ENV BITBUCKET_HOME  /opt/atlassian/stash-data
WORKDIR $STASH_INSTALL_DIR

RUN tar -xzf /atlassian-bitbucket-4.0.2.tar.gz && \
    cd atlassian-bitbucket-4.0.2               && \
    ls -la                                     && \
    rm bin/*.exe                               && \
    rm bin/*.bat                               && \
    rm lib/native/*.dll                        && \
    mv * ..                                    && \
    cd ..                                      && \
    rmdir atlassian-bitbucket-4.0.2

RUN mkdir -p                       ${BITBUCKET_HOME}                   \
    && mkdir -p                    ${BITBUCKET_HOME}/logs              \
    && mkdir -p                    ${STASH_INSTALL_DIR}                \
    && mkdir -p                    ${STASH_INSTALL_DIR}/conf/Catalina  \
    && mkdir -p                    ${STASH_INSTALL_DIR}/logs           \
    && mkdir -p                    ${STASH_INSTALL_DIR}/temp           \
    && mkdir -p                    ${STASH_INSTALL_DIR}/work           \
    && chmod -R 700                ${STASH_INSTALL_DIR}                \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${BITBUCKET_HOME}             \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${STASH_INSTALL_DIR} 

RUN grep -i port conf/server.xml &&   \
    grep -i realm conf/server.xml

VOLUME ["${STASH_INSTALL_DIR}"]

USER ${RUN_USER}:${RUN_GROUP}

# HTTP Port
EXPOSE 7990

# SSH Port
EXPOSE 7999

# Run in foreground
CMD ["./bin/start-bitbucket.sh", "-fg"]
