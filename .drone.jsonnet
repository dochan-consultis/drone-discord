local pipeline = import 'pipeline.libsonnet';
local name = 'drone-discord';

[
  pipeline.test,
  pipeline.build(name, 'linux', 'amd64')
]
