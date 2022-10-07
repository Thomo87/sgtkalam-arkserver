FROM ubuntu:latest

USER root

RUN apt-get update && \
    apt -y install software-properties-common && \
    add-apt-repository multiverse  && \
    dpkg --add-architecture i386 && \
    apt -y install lib32gcc-s1 cron sudo

RUN echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt-get update && \
    apt -y install steamcmd

RUN useradd -m steam && \
    passwd -d steam && \
    ln -s /usr/games/steamcmd /home/steam/steamcmd

RUN apt install -y perl-modules curl lsof libc6-i386 bzip2

RUN curl -sL https://git.io/arkmanager | bash -s steam && \
    ln -s /usr/local/bin/arkmanager /usr/bin/arkmanager

COPY run.sh /home/steam/run.sh
COPY log.sh /home/steam/log.sh
COPY arkmanager.cfg /etc/arkmanager/arkmanager.cfg
COPY instance.cfg /etc/arkmanager/instances/main.cfg


RUN mkdir /ark /home/steam/.steam && \
    sudo chown -R steam:steam /home/steam /ark

RUN echo "steam   ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers && \
    usermod -a -G sudo steam && \
    touch /home/steam/.sudo_as_admin_successful

ENV am_ark_SessionName="Ark Server" \
    am_serverMap="TheIsland" \
    am_ark_ServerAdminPassword="k3yb04rdc4t" \
    am_ark_MaxPlayers=10 \
    am_ark_QueryPort=27015 \
    am_ark_Port=7778 \
    am_ark_RCONPort=32330 \
    am_arkwarnminutes=15

WORKDIR /home/steam
USER steam
RUN /usr/games/steamcmd +quit

VOLUME /ark

CMD [ "./run.sh" ]