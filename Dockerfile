FROM ubuntu:20.10

RUN apt-get update \ 
    && apt-get -y install skopeo jq docker.io

COPY . /app

CMD ["/app/mirror_master.sh"]
