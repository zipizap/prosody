# Prosody XMPP server for Raspberry Pi

This docker image provides you with a configured [Prosody](https://prosody.im/) XMPP server. The image is intended to run on a Raspberry Pi (as it is based on _balenalib/rpi-raspbian_).
The server was tested using the Android App [Conversations](https://conversations.im/) and the Desktop client [Gajim](https://gajim.org).

While Conversations got everything set-up out-of-the-box, Gajim was used with the following extensions:

* HttpUpload
* Off-The-Record Encryption
* OMEMO (requires _python-axolotl_ to be installed)
* Url Image preview

## Table of Contents

- [Prosody XMPP server for Raspberry Pi](#prosody-xmpp-server-for-raspberry-pi)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Image Details](#image-details)
    - [Ports](#ports)
    - [Directories](#directories)
    - [Run](#run)
    - [Configuration](#configuration)
      - [DNS](#dns)
      - [server_contact_info](#server_contact_info)
    - [Debugging](#debugging)
    - [Extend](#extend)
    - [Upgrade](#upgrade)
  - [Test your server](#test-your-server)

## Features

* Secure by default
  * SSL certificate required
  * End-to-end encryption required (using [OMEMO](https://conversations.im/omemo/) or [OTR](https://en.wikipedia.org/wiki/Off-the-Record_Messaging))
* Data storage
  * SQLite message store
  * Configured file upload and image sharing
* Allows registration
* Multi-user chats

## Requirements

* You need a SSL certificate. I recommend [LetsEncrypt](https://letsencrypt.org/) for that.
* Your Raspberry Pi should have docker set-up and running. You could use the Raspberry image for [Hypriot OS](http://blog.hypriot.com/downloads/) to get started quickly.

## Image Details

### Ports

The following ports are exposed:

* 5000: proxy65 port used for file sharing
* 5222: c2s port (client to server)
* 5269: s2s port (server to server)
* 5347: XMPP component port
* 5280: BOSH / websocket port
* 5281: Secure BOSH / websocket port

### Directories

* Data: ```/usr/local/var/lib/prosody/```
  * used for SQLite file
  * used for HTTP uploads
  * this is exposed as docker volume
* Bundled modules: ```/usr/local/lib/prosody/modules/```
* Additionally installed prosody modules: ```/usr/local/lib/prosody/custom-modules/```
* Config: ```/usr/local/etc/prosody/```
  * containing the main config file called ```prosody.cfg.lua```
  * containing additional config files within ```conf.d/```
* SSL certificates: ```/usr/local/etc/prosody/certs/```
  * expects private key to be named ```prosody.key``` and certificate (fullchain) to be ```prosody.crt```

### Run

I recommend using a ```docker-compose.yml``` file:

```yaml
version: '2'

services:
  server:
    image: shaula/rpi-prosody:0.10
    ports:
      - "5000:5000"
      - "5222:5222"
      - "5269:5269"
      - "5281:5281"
    environment:
      DOMAIN: domain.tld
    volumes:
      - ./privkey.pem:/usr/local/etc/prosody/certs/prosody.key
      - ./fullchain.pem:/usr/local/etc/prosody/certs/prosody.crt
      - ./data:/usr/local/var/lib/prosody
    restart: unless-stopped
```

Boot it via: ```docker-compose up -d```

Inspect logs: ```docker-compose logs -f```

### Configuration

#### DNS

You need these DNS record pointing to your server:

* domain.tld
* conference.domain.tld
* proxy.domain.tld
* upload.domain.tld

where domain.tld is the environment variable DOMAIN.

#### server_contact_info

This module lets you advertise various contact addresses for your XMPP service via XEP-0157.
It is configured for the following contacts:

* abuse
* admin
* feedback
* sales
* security
* support

You can change them in [05-server_contact_info.cfg.lua](./conf.d/05-server_contact_info.cfg.lua).

### Debugging

Change to verbose logging by replacing the following config lines within ```prosody.cfg.lua```:

```lua
log = {
    {levels = {min = "info"}, to = "console"};
};
```

with:

```lua
log = {
    {levels = {min = "debug"}, to = "console"};
};
```

### Extend

There is a helper script that eases installing additional prosody modules: ```docker-prosody-module-install```

It downloads the current [prosody-modules](https://hg.prosody.im/prosody-modules/) repository. The specified modules are copied and its name is added to the ```modules_enabled``` variable within ```conf.d/01-modules.cfg.lua```.

There is also ```docker-prosody-module-copy``` which copies the specified modules but does not add them to the ```modules_enabled``` variable within ```conf.d/01-modules.cfg.lua```.

If you need additional configuration just overwrite the respective _cfg.lua_ file or add new ones.

### Upgrade

When migrating from 0.10, you need to update the database once:

```bash
docker-compose exec server bash
prosodyctl mod_storage_sql upgrade
```

## Test your server

You can test your server with these websites:

* [IM Observatory](https://www.xmpp.net/)
* [XMPP Compliance Tester](https://compliance.conversations.im/)
