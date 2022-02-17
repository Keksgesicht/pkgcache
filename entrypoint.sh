#!/bin/sh

PKG_CONF_DIR="/config"
TEMPLATE_DIR="/etc/nginx/templates"
export PKG_PORT=8000
mkdir -p /etc/nginx/conf.d/pkg

envsubst '\$DNS_SERVER' < $TEMPLATE_DIR/nginx > /etc/nginx/nginx.conf

for PKG_NAME in $(ls $PKG_CONF_DIR); do
	export PKG_NAME
	PKG_PORT=$(( $PKG_PORT + 1 ))

	envsubst '\$PKG_NAME \$PKG_PORT' < $TEMPLATE_DIR/main >> /etc/nginx/conf.d/main.conf

	export FILE_EXCLUDE=$(cat $PKG_CONF_DIR/$PKG_NAME/exclude)
	export FILE_INCLUDE=$(cat $PKG_CONF_DIR/$PKG_NAME/include)

	envsubst '\$PKG_NAME \$PKG_PORT \$FILE_EXCLUDE \$FILE_INCLUDE' < $TEMPLATE_DIR/pkg > /etc/nginx/conf.d/pkg/$PKG_NAME.conf

	$PKG_CONF_DIR/$PKG_NAME/get-upstreams.sh | sed 's|/$||g' | shuf > /tmp/upstreams.txt
	upstream_urls=''
	unset UP_SRV_PARAM
	for MIRROR_URL in $(cat /tmp/upstreams.txt); do
		PKG_PORT=$(( $PKG_PORT + 1 ))
		export MIRROR_URL
		envsubst '\$PKG_PORT \$MIRROR_URL' < $TEMPLATE_DIR/mirror >> /etc/nginx/conf.d/pkg/$PKG_NAME.conf

		upstream_urls="$upstream_urls        server 127.0.0.1:$PKG_PORT${UP_SRV_PARAM};\n"
		UP_SRV_PARAM=" backup"
	done
	sed -i "s|PLACE_UPSTREAM_INTERNAL_HERE|$upstream_urls|" /etc/nginx/conf.d/pkg/$PKG_NAME.conf

	mkdir -p /cache/$PKG_NAME
done
