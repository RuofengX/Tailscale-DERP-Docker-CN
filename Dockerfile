FROM alpine:latest AS builder

ENV GOPROXY "https://goproxy.cn"
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

#Install GO and Tailscale DERPER
RUN apk add go
RUN go install tailscale.com/cmd/derper@main

FROM alpine:latest

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

#Install Tailscale requirements
RUN apk add curl iptables

#Install Tailscale and Tailscaled
RUN apk add tailscale

RUN mkdir -p /root/go/bin
COPY --from=builder /root/go/bin/derper /root/go/bin/derper

#Copy init script
COPY init.sh /init.sh
RUN chmod +x /init.sh

#Derper Web Ports
EXPOSE 80
EXPOSE 443/tcp
#STUN
EXPOSE 3478/udp

ENTRYPOINT /init.sh
