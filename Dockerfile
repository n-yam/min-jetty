##### MINIMIZE JRE #####
FROM eclipse-temurin:21-jdk-alpine AS min-jre

ENV JAVA_HOME=/opt/jre21

WORKDIR /tmp
RUN jlink --module-path jmods --add-modules java.xml,java.management,java.instrument,java.desktop,jdk.zipfs --output $JAVA_HOME


##### INSTALL JETTY #####
FROM alpine:3.20.3 AS jetty

ENV JAVA_HOME=/opt/jre21
ENV PATH=$PATH:/opt/jre21/bin
COPY --from=min-jre $JAVA_HOME $JAVA_HOME

ENV JETTY_HOME=/opt/jetty/home
ENV JETTY_BASE=/opt/jetty/base

WORKDIR $JETTY_BASE

RUN wget https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/12.0.13/jetty-home-12.0.13.tar.gz -O jetty.tar.gz \
    && mkdir -p $JETTY_HOME \
    && tar xzf jetty.tar.gz -C $JETTY_HOME --strip-components 1 \
    && rm jetty.tar.gz \
    && java -jar $JETTY_HOME/start.jar --add-modules=http,ee10-deploy


##### MINIMIZE JETTY ######
FROM alpine:3.20.3

ENV JAVA_HOME=/opt/jre21
ENV PATH=$PATH:/opt/jre21/bin
COPY --from=min-jre $JAVA_HOME $JAVA_HOME

ENV JETTY_HOME=/opt/jetty/home
ENV JETTY_BASE=/opt/jetty/base
COPY --from=jetty $JETTY_HOME/start.jar $JETTY_HOME/start.jar
COPY --from=jetty $JETTY_HOME/etc $JETTY_HOME/etc
COPY --from=jetty $JETTY_HOME/modules $JETTY_HOME/modules
COPY --from=jetty $JETTY_HOME/lib/logging/slf4j-api-2.0.13.jar $JETTY_HOME/lib/logging/.
COPY --from=jetty $JETTY_HOME/lib/logging/jetty-slf4j-impl-12.0.13.jar $JETTY_HOME/lib/logging/.
COPY --from=jetty $JETTY_HOME/lib/jetty-http-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jetty-server-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jetty-xml-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jetty-util-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jetty-io-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jetty-deploy-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jetty-session-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jetty-security-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jetty-ee-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jetty-ee10-webapp-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jetty-ee10-servlet-12.0.13.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_HOME/lib/jakarta.servlet-api-6.0.0.jar $JETTY_HOME/lib/.
COPY --from=jetty $JETTY_BASE $JETTY_BASE

WORKDIR $JETTY_BASE

EXPOSE 8080
CMD ["sh", "-c", "java -jar $JETTY_HOME/start.jar --version"]
