FROM ubuntu:22.04

ENV GODOT_VERSION "4.3"
ENV GODOT_RELEASE "stable"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-${GODOT_RELEASE}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux.x86_64.zip \
    && unzip -q Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux.x86_64.zip \
    && mv Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux.x86_64 /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && rm Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux.x86_64.zip

WORKDIR /app
COPY build/server.pck /app/server.pck

EXPOSE 10403/udp
EXPOSE 10403/tcp

CMD ["godot", "--headless", "--main-pack", "server.pck", "--server"]
