## deno-ipfs-gateway <!-- omit in toc -->

### TOC <!-- omit in toc -->
- [Require](#require)
- [Usage](#usage)
  - [Preparations](#preparations)
  - [Commands](#commands)
- [System Designs](#system-designs)
  - [Configurations](#configurations)
  - [Configuration Chart](#configuration-chart)
  - [Sequence Diagrams](#sequence-diagrams)

### Require
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Gemster](https://github.com/redpeacock78/gemster/tree/master) (Require [Crystal](https://crystal-lang.org/) >= 1.11.2)

### Usage
#### Preparations
Create `.env` directly under the project and fill it in as follows
```
TUNNEL_TOKEN="List your Cloudflare Tunnels key here"
NETDATA_TUNNEL_TOKEN="List your Cloudflare Tunnels key here"
```
#### Commands
- Launch
  ```bash
  $ gemster up
  ```
- Image build and launch
  ```bash
  $ gemster build-up
  ```
- Termination
  ```bash
  $ gemster down
  ```
- Display of list of callable tasks
  ```bash
  $ gemster
  ```

### System Designs
#### Configurations
- Main Services
  - cloudflared([zoeyvid/cloudflared](https://hub.docker.com/r/zoeyvid/cloudflared))
  - Nginx([nginx](https://hub.docker.com/_/nginx))
  - Deno IPFS Proxy([frolvlad/alpine-glibc](https://hub.docker.com/r/frolvlad/alpine-glibc/))
    - [Deno](https://deno.com/)
      - [Hono](https://hono.dev/)
      - [ipfs](https://github.com/deno-libs/ipfs)
      - [magika](https://www.npmjs.com/package/magika)
      - [mime](https://www.npmjs.com/package/mime)
      - [file-type](https://www.npmjs.com/package/file-type)
    - [Kubo](https://github.com/ipfs/kubo)
- Monitor Services
  - cloudflared([zoeyvid/cloudflared](https://hub.docker.com/r/zoeyvid/cloudflared))
  - Netdata([netdata/netdata](https://hub.docker.com/r/netdata/netdata))
- Other Services
  - Autoheal([willfarrell/autoheal](https://hub.docker.com/r/willfarrell/autoheal))
#### Configuration Chart
```mermaid
%% { init: { 'flowchart': { 'curve': 'liner' } } }%%
flowchart TD
subgraph CloudflareGroup["🌥 Cloudflare"]
  subgraph ZeroTrustGroup["Zero Trust"]
    TU1{{"🚇 Tunnels"}}
    AC1{{"🔐 Access"}}
    TU2{{"🚇 Tunnels"}}
  end
end

subgraph OCIGroup["🌥 Oracle Cloud Infrastracrure"]
  subgraph OCICompute["💻 Bare Metal Compute"]
    subgraph DockerGroup["🐳 Docker Compose"]
      subgraph MainServiceGroup["Main Services"]
        subgraph Nginx["📦 Nginx"]
          NG1[["Proxy<br>Port: 80"]] <-.-> |proxy_cache| NG2[["Cache"]]
        end
        DO1["📦 Cloudflared"] --> NG1
        DO1 -.-> |service_healthy| Nginx
        subgraph DenoIPFSProxyGroup["Deno IPFS Proxy Services"]
          direction TB
          subgraph DenoIPFSProxy01["📦 Deno IPFS Proxy"]
            direction TB
            DI011[["Proxy<br>Port: 8000"]] --> |cat| DI012[["IPFS<br>Port: 4001"]]
          end
          subgraph DenoIPFSProxy02["📦 Deno IPFS Proxy"]
            direction TB
            DI021[["Proxy<br>Port: 8000"]] --> |cat| DI022[["IPFS<br>Port: 4001"]]
          end
          subgraph DenoIPFSProxy03["📦 Deno IPFS Proxy"]
            direction TB
            DI031[["Proxy<br>Port: 8000"]] --> |cat| DI032[["IPFS<br>Port: 4001"]]
          end
          subgraph DenoIPFSProxy04["📦 Deno IPFS Proxy"]
            direction TB
            DI041[["Proxy<br>Port: 8000"]] --> |cat| DI042[["IPFS<br>Port: 4001"]]
          end
          subgraph DenoIPFSProxy05["📦 Deno IPFS Proxy"]
            direction TB
            DI051[["Proxy<br>Port: 8000"]] --> |cat| DI052[["IPFS<br>Port: 4001"]]
          end
        end
        NG1 --> |upstream| DenoIPFSProxyGroup
        Nginx -.-> |service_healthy| DenoIPFSProxyGroup
      end
      subgraph MonitorGroup["Monitor Services"]
        DO2["📦 Cloudflared"] --> DO3["📦 Netdata<br>Port: 19999"]
      end
      subgraph OtherGroup["Other Services"]
        DO4["📦 Autoheal"]
      end
      DO4 -..-> |autoheal=true| MainServiceGroup
      DO4 -..-> |autoheal=true| MonitorGroup
    end
    Nginx <-..-> |/etc/nginx/conf.d| FS1[/"📁 ./conf"/]
    Nginx <-..-> |/var/cache/nginx/| FS2[/"📁 ./nginx"/]
    DO4 <-..-> FS3[/"📁 /var/run/docker.sock"/]
    DO3 -..-> FS3
    DO3 -..-> |/host/sys| FS4[/"📁 /sys"/]
    DO3 -..-> |/host/proc| FS5[/"📁 /proc"/]
    DO3 -..-> |/host/etc/passwd| FS6[/"📁 /etc/passwd"/]
    DO3 -..-> |/host/etc/group| FS7[/"📁 /etc/group"/]
    DO3 -..-> |/host/etc/os-release| FS8[/"📁 /etc/os-release"/]
    DO3 -..-> |/host/var/log/| FS9[/"📁 /var/log"/]
    DenoIPFSProxyGroup <-.-> |/ipfs| FS10[/"📁 ./.ipfs"/]
    DenoIPFSProxyGroup <-.-> FS3
  end
end

OU2["👤 Users"] --> TU1 ---> DO1
OU1["👤 Admin"] --> AC1 --> TU2 --> DO2
DenoIPFSProxyGroup ---> IPFSNetwork([IPFS Network])

style CloudflareGroup fill-opacity:0,stroke:#ff6d37,stroke-width:5px
style ZeroTrustGroup fill-opacity:0,stroke:#ff6d37,stroke-width:3px
style OCIGroup fill-opacity:0,stroke:#53565a,stroke-width:5px
style OCICompute fill-opacity:0,stroke:#53565a,stroke-width:4px
style DockerGroup fill-opacity:0,stroke:#00f,stroke-dasharray:5 5,stroke-width:3px
style MainServiceGroup fill-opacity:0,stroke:#ff4500,stroke-dasharray:5 5,stroke-width:2px
style MonitorGroup fill-opacity:0,stroke:#228b22,stroke-dasharray:5 5,stroke-width:2px
style OtherGroup fill-opacity:0,stroke:#ffa500,stroke-dasharray:5 5,stroke-width:2px
style DenoIPFSProxyGroup fill-opacity:0,stroke:#66cdaa,stroke-dasharray:5 5
```
#### Sequence Diagrams
```mermaid
sequenceDiagram
    actor Users
    Users ->> Cloudflare Tunnels: GET
    Cloudflare Tunnels ->> cloudflared: GET
    cloudflared ->>+ Nginx: GET
    alt Cache Data Return
      Nginx ->> Nginx: Cache Data Return
      Nginx -->> cloudflared: Response
      cloudflared -->> Cloudflare Tunnels: Response
      Cloudflare Tunnels -->> Users: Response
    end
    Nginx ->>+ Proxy: GET
    Proxy ->>+ IPFS API: Query Cat Endpoint of the IPFS API
    alt Timeout Error
      Nginx ->> Nginx: Timeout Error
      Nginx -->> cloudflared: Timeout Error Redsponse
      cloudflared -->> Cloudflare Tunnels: Timeout Error Response
      Cloudflare Tunnels -->> Users: Timeout Error Response
    end
    Note over IPFS API: Get contents from IPFS Network
    IPFS API -->> Proxy: Response
    Proxy -->> Nginx: Response
    Nginx -->> cloudflared: Response
    cloudflared -->> Cloudflare Tunnels: Response
    Cloudflare Tunnels -->> Users: Response
    alt Error
      IPFS API -->>- Proxy: Error Response
      Proxy -->>- Nginx: Error Response
      Nginx -->>- cloudflared: Error Redsponse
      cloudflared -->> Cloudflare Tunnels: Error Response
      Cloudflare Tunnels -->> Users: Error Response
    end
```
