FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3 python3-pip systemd tzdata && \ 
    apt-get install -y curl && apt-get clean

WORKDIR /app

COPY script.py .

COPY myapp.service /etc/systemd/system/myapp.service

RUN systemctl enable myapp.service

CMD ["python3", "script.py"]
