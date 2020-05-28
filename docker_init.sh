#!/bin/bash

# install languages
if [ "${CRAWLAB_SERVER_LANG_NODE}" = "Y" ] || [ "${CRAWLAB_SERVER_LANG_JAVA}" = "Y" ];
then
	echo "installing languages"
	echo "you can view log at /var/log/install.sh.log"
	/bin/sh /app/backend/scripts/install.sh >> /var/log/install.sh.log 2>&1 &
fi

# generate ssh
ssh-keygen -q -t rsa -N "" -f ${HOME}/.ssh/id_rsa

# ssh config
touch ${HOME}/.ssh/config && chmod 600 ${HOME}/.ssh/config
cat > ${HOME}/.ssh/config <<EOF
Host *
  StrictHostKeyChecking no
EOF

# start backend
crawlab-server
