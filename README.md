subnet: 172.17.0.0/16
gateway: 172.17.0.1

Host (can be multiple/individual hosts)
 |
 +-- traefik:2.10.5, 0.0.0.0:80/tcp, :::80->80/tcp
 |                   0.0.0.0:443/tcp, :::443->443/tcp
 |
 +-- app:<commit hash>, 3000/tcp (or via UNIX socket)
 |
 +-- postgresql:16.1, 0.0.0.0:5432/tcp, :::5432/tcp->5432/tcp


Jail environments:

zroot/JE/traefik-2.10.5
zroot/JE/app-<commit hash>
zroot/JE/postgresql-16.1

Jail datasets:

zroot/JAIL/traefik/<jail environment> (ACTIVE) interface=lo
zroot/JAIL/app/<jail environment> (ACTIVE) mountpoint=/rails, interface=lo
zroot/JAIL/postgresql/<jail environment> (ACTIVE) interface=lo
zroot/JAIL/postgresql/data16 mountpoint=/postgresql/db/postgres/data16 postgresql_data dir

Host: (Eventually read-only)
zroot/ROOT/<boot environment> (NR) mountpoint=/

# db
PostgreSQL 16.1
The port on FreeBSD uses PG_UID=770 (/var/db/postgres/data16), Docker uses 999 (/var/lib/postgresql)
Both set en_US.UTF-8 by default

Docker sets
ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data

So we need to expose/create a similar dataset
zroot/JAIL/postgresql/data16 which mounts to /db/postgres (or /db/postgres/data16) (or similar)

# traefik
traefik 2.10.5
The Docker image is straightforward
Previoulsy, we used nginx with BROTLI and HEADERS_MORE modules.
Additionally, we install acme.sh (optionally)

# app
The Rails Docker image installs Ruby 3.2.2, WORKDIR /rails, sets the following
env vars:
RAILS_ENV="production"
BUNDLE_DEPLOYMENT="1"
BUNDLE_PATH="/usr/local/bundle"
BUNDLE_WITHOUT="development"
Builds the gems, precompile assets, creates a user/group rails:rails, prepares
the database, and runs rails server on port 3000

Try with FreeBSD ruby pkg/gems again, now that we are building them.
Otherwise, stay with rbenv

Overall is a similar structure to what is being used for
development/production on FreeBSD with jails.
All jails need to be VNET jails and have the host use ipfw/pf to
forward/expose ports.  Previously we used either raw sockets or loopback
interfaces from the host directly.  The performance penalty should be
negligible.
