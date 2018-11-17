FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y wget gnupg git locales ansible python3 python3-requests python3-pip
    
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update && \
    apt-get install -y esl-erlang=1:21.1 elixir=1.7.3-1

RUN pip3 install awscli

RUN locale-gen en_US.UTF-8
ENV LANG en_US.utf8
ENV LC_ALL en_US.utf8

RUN mix local.hex --force
RUN mix local.rebar --force

COPY . /app
WORKDIR /app
