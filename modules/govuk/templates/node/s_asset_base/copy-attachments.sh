#!/bin/bash

set -e

export DIRECTORY_TO_COPY=$1

set -u

# The default Icinga passive alert assumes that the script failed
NAGIOS_CODE=2
NAGIOS_MESSAGE="CRITICAL: Full attachments sync failed"

# Triggered whenever this script exits, successful or otherwise. The values
# of CODE/MESSAGE will be taken from that point in time.
function nagios_passive () {
  printf "<%= @ipaddress %>\tFull attachments sync\t${NAGIOS_CODE}\t${NAGIOS_MESSAGE}\n" | /usr/sbin/send_nsca -H alert.cluster >/dev/null
}

trap nagios_passive EXIT

usage() {
  echo "USAGE: $0 <directory_to_copy>"
  echo
  echo "Copies attachments in <directory_to_copy> to each asset slave"
  echo
  exit 1
}

if [ ! $DIRECTORY_TO_COPY ]; then
 usage
fi

ASSET_SLAVE_NODES=$(/usr/local/bin/govuk_node_list -c asset_slave)

for NODE in $ASSET_SLAVE_NODES; do
  if rsync -aqe "ssh -q" --delete "$DIRECTORY_TO_COPY/" $NODE:$DIRECTORY_TO_COPY; then
    logger -t copy_attachments "Attachments copied to $NODE successfully"
  else
    logger -t copy_attachments "Attachments errored while copying to $NODE"
  fi
done

<% if @s3_bucket %>
  if envdir /etc/govuk/aws/env.d /usr/local/bin/s3cmd --server-side-encryption sync --skip-existing --delete-removed "$DIRECTORY_TO_COPY/" "s3://<%= @s3_bucket -%>$DIRECTORY_TO_COPY/"; then
    logger -t copy_attachments "Attachments copied to S3 (<%= @s3_bucket -%>) successfully"
  else
    logger -t copy_attachments "Attachments errored while copying to S3 (<%= @s3_bucket -%>)"
  fi
<% end %>

if [ $? == 0 ]
  then
    STATUS=0
  else
    STATUS=1
fi

if [ $STATUS -eq 0 ]; then
  NAGIOS_CODE=0
  NAGIOS_MESSAGE="Full attachments sync succeeded"
fi

exit $STATUS
