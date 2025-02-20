{
  test:: {
    kind: 'pipeline',
    name: 'testing',
    platform: {
      os: 'linux',
      arch: 'amd64',
    },
    steps: [
      {
        name: 'vet',
        image: 'golang:1.16',
        pull: 'always',
        commands: [
          'make vet',
        ],
        volumes: [
          {
            name: 'gopath',
            path: '/go',
          },
        ],
      },
      {
        name: 'lint',
        image: 'golang:1.16',
        pull: 'always',
        commands: [
          'make lint',
        ],
        volumes: [
          {
            name: 'gopath',
            path: '/go',
          },
        ],
      },
      {
        name: 'misspell',
        image: 'golang:1.16',
        pull: 'always',
        commands: [
          'make misspell-check',
        ],
        volumes: [
          {
            name: 'gopath',
            path: '/go',
          },
        ],
      },
      {
        name: 'test',
        image: 'golang:1.16',
        pull: 'always',
        environment: {
          WEBHOOK_ID: { 'from_secret': 'webhook_id' },
          WEBHOOK_TOKEN: { 'from_secret': 'webhook_token' },
        },
        commands: [
          'make test',
          'make coverage',
        ],
        volumes: [
          {
            name: 'gopath',
            path: '/go',
          },
        ],
      },
    ],
    volumes: [
      {
        name: 'gopath',
        temp: {},
      },
    ],
  },

  build(name, os='linux', arch='amd64'):: {
    kind: 'pipeline',
    name: os + '-' + arch,
    platform: {
      os: os,
      arch: arch,
    },
    steps: [
      {
        name: 'build-push',
        image: 'golang:1.16',
        pull: 'always',
        environment: {
          CGO_ENABLED: '0',
        },
        commands: [
          'go build -v -ldflags \'-X main.build=${DRONE_BUILD_NUMBER}\' -a -o release/' + os + '/' + arch + '/' + name,
        ],
        when: {
          event: {
            exclude: [ 'tag' ],
          },
        },
      },
      {
        name: 'build-tag',
        image: 'golang:1.16',
        pull: 'always',
        environment: {
          CGO_ENABLED: '0',
        },
        commands: [
          'go build -v -ldflags \'-X main.version=${DRONE_TAG##v} -X main.build=${DRONE_BUILD_NUMBER}\' -a -o release/' + os + '/' + arch + '/' + name,
        ],
        when: {
          event: [ 'tag' ],
        },
      },
      {
        name: 'executable',
        image: 'golang:1.16',
        pull: 'always',
        commands: [
          './release/' + os + '/' + arch + '/' + name + ' --help',
        ],
      },
      {
        name: 'dryrun',
        image: 'plugins/docker:' + os + '-' + arch,
        pull: 'always',
        settings: {
          daemon_off: false,
          dry_run: true,
          tags: os + '-' + arch,
          dockerfile: 'docker/Dockerfile.' + os + '.' + arch,
          repo: 'theglow666/' + name,
          cache_from: 'theglow666/' + name,
        },
        when: {
          event: [ 'pull_request' ],
        },
      },
      {
        name: 'publish',
        image: 'plugins/docker:' + os + '-' + arch,
        pull: 'always',
        settings: {
          daemon_off: 'false',
          auto_tag: true,
          auto_tag_suffix: os + '-' + arch,
          dockerfile: 'docker/Dockerfile.' + os + '.' + arch,
          repo: 'theglow666/' + name,
          cache_from: 'theglow666/' + name,
          username: { 'from_secret': 'docker_username' },
          password: { 'from_secret': 'docker_password' },
        },
        when: {
          event: {
            exclude: [ 'pull_request' ],
          },
        },
      },
    ],
    depends_on: [
      'testing',
    ],
    trigger: {
      ref: [
        'refs/heads/master',
        'refs/pull/**',
        'refs/tags/**',
      ],
    },
  },

  signature(key):: {
    kind: 'signature',
    hmac: key,
  }
}
