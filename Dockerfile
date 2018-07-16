FROM openjdk:8-alpine
ENV SONAR_VERSION=7.1 \
    SONARQUBE_HOME=/opt/sonarqube \
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=
RUN addgroup -S sonarqube && adduser -S -G sonarqube sonarqube
RUN set -x \
    && apk add --no-cache gnupg unzip \
    && apk add --no-cache libressl wget \
    && apk add --no-cache su-exec \
    && apk add --no-cache bash \

    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE \

    && mkdir /opt \
    && cd /opt \
    && wget -O sonarqube.zip --no-verbose https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
    && wget -O sonarqube.zip.asc --no-verbose https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip.asc \
    && gpg --batch --verify sonarqube.zip.asc sonarqube.zip \
    && unzip sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube 
ADD sonar-scala_2.12-6.4.0-assembly.jar /opt/sonarqube/extensions/plugins/
ADD sonar-scapegoat-plugin-1.3.0.jar  /opt/sonarqube/extensions/plugins/

RUN cd /opt \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*

COPY run.sh $SONARQUBE_HOME/bin/
VOLUME ["${SONARQUBE_HOME}/conf","${SONARQUBE_HOME}/data","${SONARQUBE_HOME}/lib/bundled-plugins"]
RUN cd /opt \
    && chown -R sonarqube:sonarqube sonarqube
EXPOSE 9000
EXPOSE 9092

WORKDIR $SONARQUBE_HOME
USER sonarqube
ENTRYPOINT ["./bin/run.sh"]
