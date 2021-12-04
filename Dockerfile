# Get MiniZinc base image from the latest Ubuntu LTS
#FROM minizinc/minizinc:latest


#Dockerfile
FROM ubuntu:bionic


ARG elixir_version=1.10.4-1
ENV LANG C.UTF-8
ENV SHELL /bin/sh
ENV TERM xterm


RUN \
  apt-get update -y && \
  apt-get install -y build-essential git wget nodejs npm locales libwxgtk3.0-dev libwxbase3.0-dev libsctp1 && \
  locale-gen en_US.UTF-8



# Get the Erlang Solutions Registry Info and use apt-get to install
RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb \
    && dpkg -i erlang-solutions_2.0_all.deb \
    && apt-get update -y

RUN apt-get install -y erlang-dev erlang-parsetools
RUN apt-get install -y elixir=${elixir_version}
# Update npm
RUN npm i -g npm

# Optional
RUN apt-get install -y vim

WORKDIR /opt

## MiniZinc
ARG minizinc_version=2.5.2
ENV PATH "$PATH:/opt/MiniZincIDE/bin"
ENV LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/opt/MiniZincIDE/lib"

RUN \
wget https://github.com/MiniZinc/MiniZincIDE/releases/download/${minizinc_version}/MiniZincIDE-${minizinc_version}-bundle-linux-x86_64.tgz && \
	tar -zxvf MiniZincIDE-${minizinc_version}-bundle-linux-x86_64.tgz && \
	mv MiniZincIDE-${minizinc_version}-bundle-linux-x86_64 MiniZincIDE && \
	rm -rf MiniZincIDE-${minizinc_version}-bundle-linux-x86_64.tgz

WORKDIR /opt
 
RUN git clone https://github.com/bokner/solverview 

RUN useradd -u 9876 solverview -d /home/solverview -m

RUN chmod a+rwx /opt/solverview
RUN chown -R solverview /opt/solverview

USER solverview 

WORKDIR /home/solverview

## Make OR-Tools available
RUN wget https://github.com/google/or-tools/releases/download/v7.8/or-tools_flatzinc_ubuntu-18.04_v7.8.7959.tar.gz
RUN tar xvf or-tools_flatzinc_ubuntu-18.04_v7.8.7959.tar.gz
RUN rm or-tools_flatzinc_ubuntu-18.04_v7.8.7959.tar.gz
RUN mkdir -p /home/solverview/.minizinc/solvers
RUN cp /opt/solverview/docker_assets/com.google.or-tools.msc /home/solverview/.minizinc/solvers

WORKDIR /opt/solverview

## Install mix
RUN \
  mix local.rebar --force && \
  mix local.hex --force && \
  mix deps.get && mix compile && mix setup


EXPOSE 4000

CMD ["mix",  "phx.server"]

