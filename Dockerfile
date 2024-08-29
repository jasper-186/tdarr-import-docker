FROM debian:bookworm-slim

RUN apt-get -y update
RUN apt-get -y install mediainfo 
RUN apt-get -y install bc

WORKDIR /src
COPY tdarr-import.sh .
ENTRYPOINT [ "/bin/bash" "/src/tdarr-import.sh" ]