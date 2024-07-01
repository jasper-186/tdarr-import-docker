FROM debian:bookworm-slim

RUN apt-get -y update
RUN apt install mediainfo

WORKDIR /src
COPY tdarr-import.sh .
ENTRYPOINT [ "bin/bash" "/src/tdarr-import.sh" ]