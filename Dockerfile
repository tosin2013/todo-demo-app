## Stage 1 : build with maven builder image with native capabilities
FROM quay.io/quarkus/centos-quarkus-maven:21.3.2-java11 AS build
RUN mkdir -p /tmp/todo-demo-app
ADD . /tmp/todo-demo-app
USER root
RUN chown -R quarkus /tmp/todo-demo-app
USER quarkus
RUN  ls  /tmp/todo-demo-app/pom.xml && mvn -f /tmp/todo-demo-app/pom.xml -Pnative clean package

## Stage 2 : create the docker final image
FROM registry.access.redhat.com/ubi8/ubi-minimal
WORKDIR /usr/src/app/target/
COPY --from=build /tmp/todo-demo-app/target/*-runner /usr/src/app/target/application
RUN chmod 775 /usr/src/app/target
EXPOSE 8080
CMD ["./application", "-XX:+PrintGC", "-XX:+PrintGCTimeStamps", "-XX:+VerboseGC", "+XX:+PrintHeapShape", "-Xmx128m", "-Dquarkus.http.host=0.0.0.0"]