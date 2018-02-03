[Unit]
Description=consul
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=30
RestartSec=10
Restart=always
ExecStartPre=-/usr/bin/docker kill consul
ExecStartPre=-/usr/bin/docker rm consul
ExecStartPre=-/usr/bin/docker pull consul:${consul_version}
ExecStart=/usr/bin/docker run --name consul --log-driver='syslog' -e 'CONSUL_LOCAL_CONFIG=${consul_local_config}' \
  -e CONSUL_CLIENT_INTERFACE='eth0' -e CONSUL_BIND_INTERFACE='eth0' \
  --network=host consul:${consul_version} agent -server -ui \
  -bootstrap-expect=${bootstrap_expect} -node=${node}

[Install]
WantedBy=multi-user.target