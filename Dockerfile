FROM ubuntu:22.10 as basekde

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y git cmake dialog g++ vim tar gperf

RUN apt install -y \
    qtbase5-dev \
    qtscript5-dev \
    libqt5x11extras5-dev \
    libqt5webkit5-dev \
    libqt5xmlpatterns5-dev \
    libqt5svg5-dev \
    qttools5-dev \
    qtdeclarative5-dev

RUN apt install -y \
    libphonon4qt5-dev \
    libboost-all-dev \
    flex \
    bison \
    docbook-xsl \
    libxml2-utils \
    libical-dev 

RUN useradd -d /home/kdedev -m kdedev && \
    mkdir /work /qt && \
    chown kdedev /work /qt
RUN ln -s /home/kdedev/.kdesrc-buildrc /root/.kdesrc-buildrc && \
    ln -s /home/kdedev/kdesrc-build /root/kdesrc-build

RUN apt install -y sudo && echo 'kdedev ALL=NOPASSWD: ALL' >> /etc/sudoers
USER kdedev
ENV HOME /home/kdedev
WORKDIR /home/kdedev/

RUN git config --global user.name "kdedev-podman" && \
    git config --global user.email "kdedev-podman@fake.server" && \
    git clone https://invent.kde.org/sdk/kdesrc-build.git

RUN cd kdesrc-build && \
    yes | ./kdesrc-build --initial-setup && \
    ./kdesrc-build --metadata-only

ENV PATH="${PATH}:/home/kdedev/kdesrc-build/"

CMD ["bash"]


FROM basekde AS kate-dev

# Dependencies for runtime kate, kate plugins or useful tools should be placed here
RUN sudo apt install -y clangd

RUN kdesrc-build kate

CMD ["kate"]

