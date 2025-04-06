# OpenVPN client + SOCKS proxy updated for easy use with PIA
# Usage:
# Create configuration (.ovpn), mount it in a volume
# docker run --volume=something.ovpn:/ovpn.conf:ro --device=/dev/net/tun --cap-add=NET_ADMIN
# Connect to (container):1080
# Note that the config must have embedded certs
# See `start` in same repo for more ideas

FROM alpine:3.12

COPY sockd.sh /usr/local/bin/

RUN true \
    && apk add --update-cache dante-server openvpn bash openresolv openrc \
    && rm -rf /var/cache/apk/* \
    && chmod a+x /usr/local/bin/sockd.sh \
    && wget -q https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip \
    && mkdir -p /openvpn/ \
    && mkdir -p /openvpn/udp-strong \
    && unzip -q openvpn-strong.zip -d /openvpn/udp-strong \
    && true

COPY sockd.conf /etc/

ENTRYPOINT [ \
    "/bin/bash", "-c", \
    "cd /etc/openvpn &&  echo \"$USERNAME\" > /openvpn/auth.txt && echo \"$PASSWORD\" >> /openvpn/auth.txt && chmod 400 /openvpn/auth.txt && /usr/sbin/openvpn --config /openvpn/udp-strong/$REGION.ovpn --auth-user-pass /openvpn/auth.txt --script-security 2 --up /usr/local/bin/sockd.sh" \
    ]
