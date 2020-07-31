# QMK Web Stack

This is a container repository that makes developing against the QMK web services (Configurator, API, and the Compiler) easier. After cloning this repo you can easily setup a web stack using either Docker or the python and jekyll development servers on your local machine.

# Docker

We use Docker Compose to start and run the services required for QMK Configurator. Setting up a dev environment is a pretty simple process.

## Getting Started

1. Install [Docker](https://www.docker.com/) or [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Clone [qmk_web_stack](https://github.com/qmk/qmk_web_stack):
   `git clone -r https://github.com/qmk/qmk_web_stack`
3. Fix the submodule checkouts
   `./fix-submodules.sh`
3. Build the Docker containers
   `cd qmk_web_stack`
   `docker-compose build`
4. Start the containers
   `docker-compose up`
5. Populate the database
   `./populate_api.sh`
6. Visit your local configurator: <http://127.0.0.1:5000/>

## Working With Your Environment

You are now ready to develop on your local environment. There are some things you can do outside the normal docker compose workflow that are helpful when developing features.

### Running Tests

There are some functional tests for the qmk_compiler code. You can run them with the provided script:

```sh
cd ~/qmk_web_stack
./run_tests.sh
```

If you want to run a subset of tests you can pass the fully resolved name to the test. Usually this is `&lt;test_module&gt;.&lttest_function_name&gt;`. For example you could pass in `test_qmk_compiler.test_0010_keyboard_list` to run only that test. You should be aware that `test_qmk_compiler.test_0000_checkout_qmk_skip_cache` and `test_qmk_compiler.test_9999_teardown` are always run because some of the tests depend on them.

Example:

```sh
cd ~/qmk_web_stack
./run_tests.sh test_qmk_compiler.test_0010_keyboard_list
```

### Controlling which git repositories are used

The QMK API will clone and update `qmk_firmware` as needed. By default this means the `master` branch of <https://github.com/qmk/qmk_firmware>. You can set environment variables for `qmk_compiler` and `qmk_api` inside `docker-compose.yml` to change this default. If you want to change the git branch for all repositories at once (qmk_firmware, chibios, chibios-contrib) you can set `GIT_BRANCH`. Otherwise you can change the branch on a repo by repo basis. You must set the git url for all repos individually.

The default environment variables are:

```
QMK_GIT_BRANCH: master
QMK_GIT_URL: https://github.com/qmk/qmk_firmware.git
CHIBIOS_GIT_BRANCH: master
CHIBIOS_GIT_URL: https://github.com/qmk/ChibiOS
CHIBIOS_CONTRIB_GIT_BRANCH: master
CHIBIOS_CONTRIB_GIT_URL: https://github.com/qmk/ChibiOS-Contrib
PRINTF_GIT_BRANCH: master
PRINTF_GIT_URL: https://github.com/qmk/printf
LUFA_GIT_BRANCH: master
LUFA_GIT_URL: https://github.com/qmk/lufa
VUSB_GIT_BRANCH: master
VUSB_GIT_URL: https://github.com/qmk/v-usb
```

### Populating the API

One of the key features of the API is the parsing of qmk_firmware to build a database about QMK keyboards and keymaps. There are two ways to start this process:

1. `populate_api.sh`: This script will run the update process directly, bypassing the normal infrastructure.
2. `trigger_update.sh`: This script triggers an update using the same pathway as `qmk_bot`- it sets a flag in redis which is acted upon by `qmk_api_tasks`.

Normally you will want to use method #1. If you need to test method #2 you will also need to start the `qmk_api_tasks` service, which is not started by default.

### Using and testing the Discord bot

QMK API uses the Discord webhook API to send messages to #configurator_log. If you'd like to use this with your own account you will need to configure a Discord webhook and set that URL here. By default this feature is disabled.

```
DISCORD_WEBHOOK_URL: <unset>
DISCORD_WEBHOOK_INFO_URL: <DISCORD_WEBHOOK_URL>
DISCORD_WEBHOOK_WARNING_URL: <DISCORD_WEBHOOK_URL>
DISCORD_WEBHOOK_ERROR_URL: <DISCORD_WEBHOOK_URL>
```

### qmk_api_tasks

The `qmk_api_tasks` service serves two roles- it continually tests keyboards to ensure they're compatible with Configurator, and it handles routine maintenance such as `qmk_firmware` updates and S3 cleanup. You typically will not need to run this service except for specific purposes, such as working on `qmk_api_tasks` itself or exercising the backend infrastructure.

To start `qmk_api_tasks` you will use the `run_qmk_api_tasks.sh` script:

```sh
cd ~/qmk_web_stack
./run_qmk_api_tasks.sh
```

### Storage Cleanup

If you need to manually clean your S3 storage you can use the `cleanup_storage.sh` script:

```sh
cd ~/qmk_web_stack
./cleanup_storage.sh
```
