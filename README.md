# drone-[discord](https://discordapp.com)

![logo](images/discord-logo.png)

 **Change compared to [appleboy/drone-discord](https://github.com/appleboy/drone-discord) are :**
 * **single property for setting webhook url**
 * **default message when `message` parameter is not provided** 

***

Drone plugin for sending message to Discord channel using Webhook.

Webhooks are a low-effort way to post messages to channels in Discord. They do not require a bot user or authentication to use. See more [api document information](https://discordapp.com/developers/docs/resources/webhook). For the usage information and a listing of the available options please take a look at [the docs](http://plugins.drone.io/appleboy/drone-discord/).

Sending discord message using a binary, docker or [Drone CI](http://docs.drone.io/).

## Features

* [x] Send Multiple Messages
* [x] Send Multiple Files

## Build a binary

With `Go` installed

```sh
go get -u -v github.com/theglow666/drone-discord
```

or build the binary with the following command:

```sh
export GOOS=linux
export GOARCH=amd64
export CGO_ENABLED=0
export GO111MODULE=on

go test -cover ./...

go build -v -a -tags netgo -o release/linux/amd64/drone-discord
```

## Usage

There are three ways to send notification.

### Usage from pipeline
```
- name: discord_notification
  image: theglow666/drone-discord
  settings:
    webhook:
      from_secret: discord_webhook
```

#### Optionally with message

```
- name: discord_notification
  image: theglow666/drone-discord
  settings:
    webhook:
      from_secret: discord_webhook
    message: "{{#success build.status}} ✅  Build #{{build.number}} of `{{repo.name}}` succeeded.\n\n📝 Commit by {{commit.author}} on `{{commit.branch}}`:\n``` {{commit.message}} ```\n🌐 {{ build.link }}\n\n ✅ duration: {{duration build.started build.finished}} \n\n ✅ started: {{datetime build.started \"2006/01/02 15:04\" \"Asia/Taipei\"}} \n\n ✅ finished: {{datetime build.finished \"2006/01/02 15:04\" \"Asia/Taipei\"}} {{else}} ❌  Build #{{build.number}} of `{{repo.name}}` failed.\n\n📝 Commit by {{commit.author}} on `{{commit.branch}}`:\n``` {{commit.message}} ```\n🌐 {{ build.link }}\n\n ✅ duration: {{duration build.started build.finished}} \n\n ✅ started: {{datetime build.started \"2006/01/02 15:04\" \"Asia/Taipei\"}} \n\n ✅ finished: {{datetime build.finished \"2006/01/02 15:04\" \"Asia/Taipei\"}}{{/success}}\n"
```



### Usage from binary

```bash
drone-discord \
  --webhook xxxx
```

### Usage from docker

```bash
docker run --rm \
  -e WEBHOOK=xxxxxxx \
  -e WAIT=false \
  -e TTS=false \
  -e USERNAME=test \
  -e AVATAR_URL=http://example.com/xxxx.png \
  theglow666/drone-discord
```

### Usage from drone ci

#### Send Notification

Execute from the working directory:

```sh
docker run --rm \
  -e WEBHOOK=xxxxxxx \
  -e WAIT=false \
  -e TTS=false \
  -e USERNAME=test \
  -e AVATAR_URL=http://example.com/xxxx.png \
  -e MESSAGE=test \
  -e DRONE_REPO_OWNER=appleboy \
  -e DRONE_REPO_NAME=go-hello \
  -e DRONE_COMMIT_SHA=e5e82b5eb3737205c25955dcc3dcacc839b7be52 \
  -e DRONE_COMMIT_BRANCH=master \
  -e DRONE_COMMIT_AUTHOR=appleboy \
  -e DRONE_COMMIT_AUTHOR_EMAIL=appleboy@gmail.com \
  -e DRONE_COMMIT_MESSAGE=Test_Your_Commit \
  -e DRONE_BUILD_NUMBER=1 \
  -e DRONE_BUILD_STATUS=success \
  -e DRONE_BUILD_LINK=http://github.com/appleboy/go-hello \
  -e DRONE_JOB_STARTED=1477550550 \
  -e DRONE_JOB_FINISHED=1477550750 \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  theglow666/drone-discord
```

You can get more [information](DOCS.md) about how to use this plugin in drone.

## Testing

Test the package with the following command:

```sh
make test
```
