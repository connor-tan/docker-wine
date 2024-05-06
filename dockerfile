FROM ubuntu:jammy

SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

ENV \
  LANG='C.UTF-8' \
  LC_ALL='C.UTF-8' \
  TZ=Asia/Shanghai \
  WINEDEBUG=-all

RUN apt-get update \
  && apt-get install -y \
    # https://github.com/wszqkzqk/deepin-wine-ubuntu/issues/188#issuecomment-554599956
    # https://zj-linux-guide.readthedocs.io/zh_CN/latest/tool-install-configure/%5BUbuntu%5D%E4%B8%AD%E6%96%87%E4%B9%B1%E7%A0%81/
    ttf-wqy-microhei \
    ttf-wqy-zenhei \
    pulseaudio \
    pulseaudio-utils \
    xfonts-wqy \
    apt-transport-https \
    ca-certificates \
    cabextract \
    curl \
    gnupg2 \
    gosu \
    software-properties-common \
    tzdata \
    unzip \
    wget \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -fr /tmp/*

# https://wiki.winehq.org/Debian
RUN dpkg --add-architecture i386 \
  && mkdir -pm755 /etc/apt/keyrings \
  && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
  && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
  && echo 'i386 Architecture & Wine Repo Added' \
  \
  && apt-get update \
  && apt-get install --install-recommends -y \
    winehq-stable \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -fr /tmp/*

RUN groupadd group \
  && useradd -m -g group user \
  && usermod -a -G audio user \
  && usermod -a -G video user \
  && chsh -s /bin/bash user \
  && echo 'User Created'

ARG GECKO_VER=2.47.4
ARG MONO_VER=9.0.0

RUN mkdir -p /usr/share/wine/{gecko,mono} \
  && curl -sL -o /usr/share/wine/gecko/wine-gecko-${GECKO_VER}-x86.msi \
    "https://mirrors.tuna.tsinghua.edu.cn/winehq/wine/wine-gecko/${GECKO_VER}/wine-gecko-${GECKO_VER}-x86.msi" \
  && curl -sL -o /usr/share/wine/gecko/wine-gecko-${GECKO_VER}-x86_64.msi \
    "https://mirrors.tuna.tsinghua.edu.cn/winehq/wine/wine-gecko/${GECKO_VER}/wine-gecko-${GECKO_VER}-x86_64.msi" \
  && curl -sL -o /usr/share/wine/mono/wine-mono-${MONO_VER}-x86.msi \
    "https://mirrors.tuna.tsinghua.edu.cn/winehq/wine/wine-mono/${MONO_VER}/wine-mono-${MONO_VER}-x86.msi" \
  && chown -R user:group /usr/share/wine/{gecko,mono} \
  && echo 'Gecko & Mono Downloaded' \
  \
  && curl -sL -o /usr/local/bin/winetricks \
    https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
  && chmod +x /usr/local/bin/winetricks \
  && echo 'Winetricks Installed' \
  \
  && su user -c 'WINEARCH=win64 wine wineboot' \
  \
  # wintricks
  && su user -c 'winetricks -q msls31' \
  && su user -c 'winetricks -q ole32' \
  && su user -c 'winetricks -q riched20' \
  && su user -c 'winetricks -q riched30' \
  && su user -c 'winetricks -q cjkfonts' \
  && su user -c 'winetricks -q win7'

RUN su user -c 'wine /usr/share/wine/gecko/wine-gecko-${GECKO_VER}-x86.msi'
RUN su user -c 'wine /usr/share/wine/gecko/wine-gecko-${GECKO_VER}-x86_64.msi'
RUN su user -c 'wine /usr/share/wine/mono/wine-mono-${MONO_VER}-x86.msi'

  # Clean
RUN rm -fr /usr/share/wine/{gecko,mono} \
  && rm -fr /home/user/{.cache,tmp}/* \
  && rm -fr /tmp/* \
  && echo 'Wine Initialized'

COPY pulse-client.conf /etc/pulse/client.conf
COPY VERSION /VERSION.docker-wine
COPY src/winescript /usr/local/bin/
