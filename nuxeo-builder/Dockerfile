FROM ubuntu:16.04

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install extra tools and modules
RUN apt-get update && apt-get install -y \
        wget \
        vim \
        openjdk-8-jdk \
        maven \
        libmaven-enforcer-plugin-java \
        libmaven-dependency-plugin-java \
        ant \
        git \
        python \
        build-essential

# Install latest NodeJS and NPM 
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 7.10.1

RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
        && . $NVM_DIR/nvm.sh \
        && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g --unsafe-perm yo
RUN npm install -g grunt-cli gulp bower

# Docker is always root, bower will not run withdock root if we do not add this parameter
RUN echo '{ "allow_root": true }' > /root/.bowerrc

RUN update-alternatives --config java

ENV USER_HOME_DIR "/root"
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

RUN mkdir -p "${MAVEN_CONFIG}/repository/com/phloc/phloc-css/3.3.1"
WORKDIR "${MAVEN_CONFIG}/repository/com/phloc/phloc-css/3.3.1"
RUN wget https://devtools.jahia.com/nexus/content/repositories/public/com/phloc/phloc-css/3.3.1/phloc-css-3.3.1.jar
COPY settings.xml ${MAVEN_CONFIG}/

WORKDIR /media/build-volume/nuxeo
