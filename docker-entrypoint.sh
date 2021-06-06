#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
	echo "$0: assuming arguments for namecoind"
	set -- namecoind "$@"
fi

# Allow the container to be started with `--user`, if running as root drop privileges
if [ "$1" = 'namecoind' -a "$(id -u)" = '0' ]; then
	# Set perms on data
	echo "$0: detected namecoind"
	mkdir -p "$DATADIR"
	chmod 700 "$DATADIR"
	chown -R namecoin "$DATADIR"
	exec gosu namecoin "$0" "$@"
fi

if [ "$1" = 'namecoin-cli' -a "$(id -u)" = '0' ] || [ "$1" = 'namecoin-tx' -a "$(id -u)" = '0' ]; then
	echo "$0: detected namecoin-cli or namecoint-tx"
	exec gosu namecoin "$0" "$@"
fi

# If not root (i.e. docker run --user $USER ...), then run as invoked
echo "$0: running exec"
exec "$@"
