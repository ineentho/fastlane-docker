FROM fastlanetools/fastlane:latest
USER root
RUN apt-get update && apt-get install -y \
    less \
    && rm -rf /var/lib/apt/lists/*

USER circleci
RUN gem install fastlane
RUN mkdir -p /home/circleci/workspace
ENV HOME /home/circleci
RUN chmod a+rwx /home/circleci
WORKDIR /home/circleci/workspace
