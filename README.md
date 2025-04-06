# OpenVPN-client for PIA

This is a docker image of an OpenVPN client tied to a SOCKS proxy server.  It is
useful to isolate network changes (so the host is not affected by the modified
routing).

It is an altered version of [https://github.com/kizzx2/docker-openvpn-client-socks](https://github.com/kizzx2/docker-openvpn-client-socks) for easy use with Private Internet Access VPN. The UDP config with strong encryption is used.  

## Why?

This is arguably the easiest way to achieve "app based" routing. For example, you may only want certain applications to go through your WireGuard tunnel while the rest of your system should go through the default gateway. You can also achieve "domain name based" routing by using a [PAC file](https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_(PAC)_file) that most browsers support.

## Usage

Using docker compose:

```yaml
version: "3.4"
services:
  pia-socks:
    container_name: pia_socks
    build: docker-openvpn-client-socks
    restart: unless-stopped

    environment:
      REGION: us_east
      USERNAME: "<pia username>"
      PASSWORD: "<pia password>"
    ports:
      - 1080:1080
    networks:
      - web
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun

networks:
  web:
    external: true
```

Then connect to SOCKS proxy through through `localhost:1080` / `local.docker:1080`. For example:

```bash
curl --proxy socks5h://local.docker:1080 ipinfo.io
```

## Solutions to Common Problems

### I'm getting `RTNETLINK answers: Permission denied`

Try adding `--sysctl net.ipv6.conf.all.disable_ipv6=0` to your docker command

### DNS doesn't work

You can put a `update-resolv-conf` as your `up` script. One simple way is to put [this file](https://gist.github.com/Ikke/3829134) as `up.sh` inside your OpenVPN configuration directory.

## HTTP Proxy

You can easily convert this to an HTTP proxy using [http-proxy-to-socks](https://github.com/oyyd/http-proxy-to-socks), e.g.

```bash
hpts -s 127.0.0.1:1080 -p 8080
```
