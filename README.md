# QMK Web Stack

This is a container repository that makes developing against the QMK web services (Configurator, API, and the Compiler) easier. After cloning this repo you can easily setup a web stack using either Docker or the python and jekyll development servers on your local machine.

# Docker

We use Docker Compose to start and run the services required for QMK Configurator. Setting up a dev environment is a pretty simple process.

## Getting Started

1. Install [Docker](https://www.docker.com/) or [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Clone [qmk_web_stack](https://github.com/qmk/qmk_web_stack):  
   `git clone -r https://github.com/qmk/qmk_web_stack`
3. Build the Docker containers  
   `cd qmk_web_stack`  
   `docker-compose build`
4. Edit the file `qmk_configurator/_site/assets/js/script.js`. Change `backend_baseurl` from `https://api.qmk.fm/` to `http://127.0.0.1:5001`
5. Start the containers  
   `docker-compose up`
6. Populate the database  
   `./populate_api.sh`
7. Visit your local configurator: <http://127.0.0.1:5000/>

## Working With Your Environment

You are now ready to develop on your local environment. There are some things you can do outside the normal docker compose workflow that are helpful when developing features.

### Running Tests

There are some functional tests for the qmk_compiler code. You can run them with the provided script:

```
cd ~/qmk_web_stack
./run_tests.sh
```

### Populating the API

One of the key features of the API is the parsing of qmk_firmware to build a database about QMK keyboards and keymaps. There are two ways to start this process:

1. `populate_api.sh`: This script will run the update process directly, bypassing the normal infrastructure.
2. `trigger_update.sh`: This script triggers an update using the same pathway as `qmk_bot`- it sets a flag in redis which is acted upon by `qmk_api_tasks`.

Normally you will want to use method #1. If you need to test method #2 you will also need to start the `qmk_api_tasks` service, which is not started by default.

### qmk_api_tasks

The `qmk_api_tasks` service serves two roles- it continually tests keyboards to ensure they're compatible with Configurator, and it handles routine maintenance such as `qmk_firmware` updates and S3 cleanup. You typically will not need to run this service except for specific purposes, such as working on `qmk_api_tasks` itself or exercising the backend infrastructure.

To start `qmk_api_tasks` you will use the `run_qmk_api_tasks.sh` script:

```
cd ~/qmk_web_stack
./run_qmk_api_tasks.sh
```

### Storage Cleanup

If you need to manually clean your S3 storage you can use the `cleanup_storage.sh` script:

```
cd ~/qmk_web_stack
./cleanup_storage.sh
```
   
# Running QMK Configurator Locally

If you don't want to or can't use Docker you can setup and run the services locally. The process for doing so is rather involved, it's recommended that you use Docker if at all possible.

## Local Setup

There are several services you need to setup to run the whole stack locally.

## S3 Compatible Storage

You will need an S3 compatible storage service backing your install. You can use [S3](https://aws.amazon.com/s3/), [Spaces](https://www.digitalocean.com/docs/spaces/), or a local service such as [Minio](https://www.minio.io/). The development environment scripts assume you're using Minio on your local machine.

## Redis

We use [RQ](http://python-rq.org) to decouple compiling the firmware from the webserver. It also handles administrative tasks like cleaning up old firmware hexes. Installing and administering Redis in a production environment is beyond the scope of this document.

For development purposes, you can simply install and run redis with the default configuration.

## Backend Environment

You will need to setup a python development environment where each service can access the `qmk_compiler` code. You can use the `setup_virtualenv` script to do so:

```
cd ~/qmk_web_stack
./setup_virtualenv
```

This will leave an activate script in the `venv` directory. Make sure to source this script whenever you need to start these services:

```
cd ~/qmk_web_stack
source venv/activate-<python-version>
```

## Frontend Environment

The frontend uses [jekyll](https://github.com/jekyll/jekyll) so that we can ultimately push our work to gh-pages. Setup is pretty simple.

1. Edit the file `qmk_configurator/assets/js/script.js`. Change `backend_baseurl` from `https://api.qmk.fm/` to `http://127.0.0.1:5001`
2. Setup the dependencies  
   `cd ~/qmk_web_stack/qmk_configurator`  
   `bundle install`
   
## Starting Minio

You can start a local instance of minio using the provided script. You need to do this each time you work on the stack.

```
cd ~/qmk_web_stack
./start_minio
```

## Starting Backend Services

You can start a local instance of the backend using `start_local_server`:

```
cd ~/qmk_web_stack
./start_local_server
```

## Starting Frontend Service

Use jekyll to start the frontend service:

```
cd ~/qmk_web_stack/qmk_configurator
bundle exec jekyll serve
```

The frontend will now be available on port 4000: <http://localhost:4000/>

You will have to reload between changes as `jekyll` in it's default configuration doesn't support live reloading. If someone wants to contribute that please do.
