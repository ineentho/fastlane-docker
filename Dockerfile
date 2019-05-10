# Based on https://github.com/milch/fastlane-docker
FROM buildpack-deps:jessie as xar_builder

ENV XAR_VERSION "1.6.1"
USER root

WORKDIR /tmp

# Build xar
ADD https://github.com/downloads/mackyle/xar/xar-$XAR_VERSION.tar.gz .
RUN tar -xzf xar-$XAR_VERSION.tar.gz \
	&& mv xar-$XAR_VERSION xar \
	&& cd xar \
	&& ./autogen.sh --noconfigure \
	&& ./configure \
	&& make 

# Extract the neccesary files from the iTMSTransporter Windows installer
FROM debian:stretch-slim as itms_transporter

RUN apt-get update \
	&& apt-get install --yes \
		p7zip-full \
        curl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
    && curl https://itunesconnect.apple.com/transporter/1.9.8/iTMSTransporterToolInstaller_1.9.8.exe > installer.exe \
    && 7z x installer.exe -oitms \
    && chmod +x itms/bin/iTMSTransporter

###############
# Final image #
###############
FROM ruby:2.6-stretch

ENV PATH $PATH:/usr/local/itms/bin

# Java versions to be installed
# ENV JAVA_VERSION 8u131
# ENV JAVA_DEBIAN_VERSION 8u131-b11-1~bpo8+1
# ENV CA_CERTIFICATES_JAVA_VERSION 20161107~bpo8+1

# Needed for fastlane to work
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Required for iTMSTransporter to find Java
# ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre

USER root

# iTMSTransporter needs java installed
# We also have to install make to install xar
# And finally shellcheck
RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list \
	&& apt-get update \
	&& apt-get install --yes \
		make \
		shellcheck \
        less \
        default-jre-headless \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
    && useradd -m builder

COPY --from=xar_builder /tmp/xar /tmp/xar

RUN cd /tmp/xar \
	&& make install \
	&& rm -rf /tmp/*

COPY --from=itms_transporter /itms /itms
RUN chown -R builder:builder /itms

ENV FASTLANE_ITUNES_TRANSPORTER_PATH=/itms
ENV FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT=1

USER builder


# RUN gem install fastlane
RUN mkdir -p /home/builder/workspace
ENV HOME /home/builder
RUN chmod a+rwx /home/builder
WORKDIR /home/builder/workspace
