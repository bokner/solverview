# Get MiniZinc base image from the latest Ubuntu LTS
FROM minizinc/minizinc:latest 


ENV  LANG=en_US.UTF-8 \
    SHELL=/bin/sh \
    TERM=xterm




RUN \
  apt-get update -y && \
  apt-get install -y build-essential git wget npm locales libwxgtk3.0-gtk3-dev libwxbase3.0-dev libsctp1 && \
  locale-gen en_US.UTF-8 && \
  wget https://packages.erlang-solutions.com/erlang/debian/pool/esl-erlang_22.3.4.9-1~ubuntu~xenial_amd64.deb && \
  dpkg -i esl-erlang_22.3.4.9-1~ubuntu~xenial_amd64.deb && \
  wget https://packages.erlang-solutions.com/erlang/debian/pool/elixir_1.10.4-1~ubuntu~xenial_all.deb && \
  dpkg -i elixir_1.10.4-1~ubuntu~xenial_all.deb && \
  apt-get update -y


WORKDIR /opt

RUN git clone https://github.com/bokner/solverlview 

RUN useradd -u 9876 solverlview -d /home/solverlview -m

RUN chmod a+rwx /opt/solverlview
RUN chown -R solverlview /opt/solverlview

USER solverlview 

WORKDIR /opt/solverlview

RUN \
  mix local.rebar --force && \
  mix local.hex --force && \
  mix deps.get && mix compile && mix setup

EXPOSE 4000

CMD ["mix",  "phx.server"]

