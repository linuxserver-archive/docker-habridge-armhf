FROM lsiobase/alpine.armhf:3.7

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="<tobbenb>"

# install packages
RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	jq && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	libcap \
	openjdk8-jre && \
 echo "**** install ha-bridge ****" && \
 mkdir -p \
		/app && \
 habridge_url=$(curl -s https://api.github.com/repos/bwssytems/ha-bridge/releases/latest \
		|jq -r '.assets[].browser_download_url') && \
 curl -o \
 /app/ha-bridge.jar -L \
		${habridge_url} && \
 chown -R abc:abc \
	app/ha-bridge.jar && \
 echo "**** workaround to run habridge on port 80 as abc user ****" && \
 setcap cap_net_bind_service=+epi /usr/lib/jvm/java-1.8-openjdk/bin/java && \
 setcap cap_net_bind_service=+epi /usr/lib/jvm/java-1.8-openjdk/jre/bin/java && \
 ln -s /usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/jli/libjli.so /usr/lib/libjli.so && \
 ln -s /usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server/libjvm.so /usr/lib/libjvm.so

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8080
VOLUME /config
