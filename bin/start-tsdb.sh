#!/bin/bash
export COMPRESSION="GZ"
export HBASE_HOME=/opt/hbase

if [ ! -e /tsdb_tables_created ]; then
	echo "creating tsdb tables"
  /opt/opentsdb/src/create_table.sh && touch /tsdb_tables_created || exit 101
fi

exec /usr/local/share/opentsdb/bin/tsdb tsd --port=4242 \
		--staticroot=/usr/local/share/opentsdb/static \
    --cachedir=/tmp --auto-metric --config=/etc/opentsdb.conf
