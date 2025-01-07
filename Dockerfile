# Base image olarak Ubuntu'yu kullanıyoruz
FROM ubuntu:20.04

# Systemd ve Python için gerekli paketleri kuruyoruz
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3 python3-pip systemd tzdata && \ 
    apt-get install -y curl && apt-get clean

# Çalışma dizinini ayarla
WORKDIR /app

# Uygulama kodunu kopyala
COPY script.py .

# Systemd servisi için birim dosyasını kopyala
COPY myapp.service /etc/systemd/system/myapp.service

# Systemd servisini etkinleştir
RUN systemctl enable myapp.service

CMD ["python3", "script.py"]
