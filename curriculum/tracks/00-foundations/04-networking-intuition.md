# Networking Intuition

> **Track:** [00 — Foundations](./index.md)
> **Level:** Beginner
> **Prerequisites:** [Files and Directories](./03-files-and-directories.md)

---

## What You'll Learn

- How data travels from one computer to another
- What IP addresses, ports, and protocols mean
- The layered model of networking (without drowning in details)
- Basic diagnostic tools every developer should know

## Why It Matters

Almost every application you build communicates over a network. Understanding
the basics means you can debug connection failures, understand why APIs behave
the way they do, and reason about security.

---

## Background Reading

- [Networking: Protocols](../../../../04-networking/protocols/)
- [Networking: Tools](../../../../04-networking/tools/)

---

## Core Concepts

### IP Addresses and DNS

Every computer on a network has an IP address — its unique identifier.

- **IPv4**: `192.168.1.1` — 4 numbers, 0–255 each
- **IPv6**: `2001:db8::1` — longer, more addresses
- **localhost**: `127.0.0.1` — your own machine (also `::1` in IPv6)

**DNS** (Domain Name System) translates human names to IP addresses.
When you type `python.org`, DNS converts it to an IP before any connection happens.

### Ports

One computer can run many network services simultaneously. Ports distinguish them.

A connection is identified by: `IP address : port`

| Port | Common service |
|---|---|
| 22 | SSH (remote shell) |
| 80 | HTTP (web, unencrypted) |
| 443 | HTTPS (web, encrypted) |
| 5432 | PostgreSQL |
| 8080 | Common development server |

Your programs can listen on any port above 1024 without root privileges.

### Protocols and Layers

Networking is organized in layers — each layer uses the one below it.

```
Application   HTTP, HTTPS, SSH, FTP, DNS
Transport     TCP (reliable), UDP (fast, lossy)
Network       IP (routing across the internet)
Link          Ethernet, Wi-Fi (your local network)
```

**TCP** guarantees delivery and order — every byte arrives, in sequence.
**UDP** is fire-and-forget — faster, used for video, games, DNS.

**HTTP** sits on top of TCP. When you load a webpage:
1. DNS resolves the hostname to an IP
2. TCP connection opens to port 443
3. Your browser sends an HTTP request
4. Server sends back an HTTP response
5. TCP connection closes

### The Request/Response Pattern

HTTP and most application protocols follow request/response:

```
Client → Server:  "GET /index.html HTTP/1.1\nHost: example.com"
Server → Client:  "HTTP/1.1 200 OK\n...\n<html>...</html>"
```

This is the pattern behind every API call, web page load, and package download.

---

## Exercises

1. **DNS lookup**: Run `dig python.org` (or `nslookup python.org` on Windows).
   What IP does it resolve to? Does it change each time?

2. **See open connections**: Run `ss -tuln` (Linux) or `netstat -an` (macOS).
   What ports is your computer listening on right now?

3. **Trace a route**: Run `traceroute python.org` (or `tracert` on Windows).
   How many hops does it take? Where does it go?

4. **Make a raw HTTP request**:
   ```bash
   curl -v http://example.com 2>&1 | head -40
   ```
   Find the request headers, response headers, and status code.

---

## Check Your Understanding

- What's the difference between TCP and UDP?
- If a server is running on port 8000 on your machine, what URL do you use?
- Why does HTTPS use port 443 instead of 80?
- What happens when DNS is down but you know the IP address?

---

## Next Steps

→ [Languages: Python](../01-languages/python/index.md)
→ [Web Track](../02-web/index.md)
→ [Track Index](./index.md)
