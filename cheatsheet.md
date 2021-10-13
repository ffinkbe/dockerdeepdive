* What is docker
Docker is not a virtual machine.

A linux system is basically just the filesystem plus some processes.
```
/etc 
/bin
/...
```
A docker container is a very well isolated shell.
```
/container1/etc
           /bin
           /...

/container2/etc
           /bin
           /...
```


Docker uses namespacing like `cgroups` to restrict subprocesses to specific resources and parts of the filesystem (similar to `chroot`).

This way we get very isolated environments that are able to use the same linux kernel, meaning there is no indirection for simulated resources. Its just Linux!

Docker has two main concepts Images and Containers. Images are general templates of environments while containers are instances of environments.

Multiple containers can be started from a base image e.g. `ubuntu`. We can also create new image templates from existing containers.

* Images
A lot of base images can be found on DockerHub e.g. the ubuntu base image: https://hub.docker.com/_/ubuntu

An image can be pulled by running 
`docker pull <registry>:<port>/<image-name-path>:<tag>`

e.g. 
`docker pull registry.hub.docker.com/ubuntu:latest`
`docker pull ubuntu`


The docker client does automatically download an image if it is not available.
`docker run ubuntu`

`docker images` lists all the images you have locally available
`docker images rm <name>` delete image


* Containers
Containers are instances of images. A container can be started by running an image:
`docker run ubuntu`

`docker ps` does not show the container .. it is not running anymore
`docker ps -a` we see that the command was bash and this 

`docker run -it ubuntu /bin/sh` attach session, run shell
`docker ps` shows running images
Create a file 
exit container
`docker start <container>`
`docker exec -it /bin/bash`
`docker exec <container> touch /etc/hello_exec`

`docker stop <name>` stopping a container 
`docker container rm <name>` deleting a container

Very useful for debugging:

`docker run --rm -it ubuntu /bin/bash`

How do we get data into a container and out of a container?

Environment variables:
`docker run --rm -it --env FUN="dance" --env WORK="code" ubuntu /bin/bash`

Ports:
`docker run -p <host-port>:<container-port> <image name>` 
`docker run --rm -it -p 8080:80 ubuntu /bin/bash`

Volumes:
`docker volume create example-vol`
`docker volume ls`
`docker run --rm -it --mount source=example-vol,target=/var/my_vol ubuntu /bin/bash`

short:
`docker run --rm -it -v example-vol:/var/my_vol ubuntu /bin/bash`

you can also mount a host folder as volume
`docker run --rm -it -v /home/felix/Downloads:/var/my_vol ubuntu /bin/bash`

How can I create an image
`docker commit <container>`
but this is cumbersome..

* Dockerfiles 

To build images more easily we can use Dockerfiles. They allow to script buildable images in a more comprehensive and understandable way than using docker containers directly would. Docker defines a set of commands that we can use within a dockerfile to create the image.

Docker requires a Union file system. Such a file system saves data in form of layers. Every command in the dockerfile creates a new layer. This allows various containers to share the same filesystem since they only manipulate their own highest layer. It also allows to save time when building since only layers that changed need to be rebuild.

Most Union file systems have a limit in the amount of layers they can provide. This is why you often see chaining of many commands in one `RUN` within Dockerfiles.


```dockerfile
# COMMENT
FROM ubuntu:20.04 as build // Define base image

WORKDIR /path/to/workdir // set the default dir for docker build commands to start in

ARG myarg // Define an argument that is required for building the image, it is set as env var during the build

EXPOSE 80/udp // Document a port that will be exposed by the application, still requires the explicit port binding at docker run with `-p` 

ENV DEBUG="True" // Define environment variable

RUN apt install pip // Run command

LABEL "dfm.sagemaker.infra-version"="2.3" // Add meta data to image

COPY myscript.sh /usr/local/bin/ // copy a file/folder into the image

ADD myscript.sh /usr/local/bin/ // copy a file/folder into an image with additional swag. Allows to add from urls and using wildcards. Should only be used if copy is not enough.

VOLUME /data // turn the data folder into a volume

CMD CMD ["/bin/bash", "/usr/local/bin/example.bash"] // Command to be run when container is called without overwriting exec

ENTRYPOINT CMD ["/bin/bash", "/usr/local/bin/example.bash", "param"] // Command to be run when container is called, that can be parameterized

```

Per convention the dockerfile is called `Dockerfile` it can then be build using this command in the same folder:
`docker build -t <name>:<tag> .`

The here we build `vf_base:latest` removing all intermediate containers using the file `base.dockerfile`.
`docker build --force-rm=true -t vf_base -f base.dockerfile .`


* Docker-compose

Docker compose allows us to combine multiple containers into an application. E.g. we can define a database container, a backend and a frontend container. The docker-compose then helps us to wire up those containers, giving them their own network. Similar to single containers docker compose setups can export ports to the host and thereover interact with the outside world. All docker compose features are already available in docker itself, docker compose just makes it much simpler to configure them.

* Other docker based platforms

Kubernets, Fargate, and docker swarm are services that rely heavily on docker container. Docker container make it easy to build fully isolated environments. They can be build and tested locally and therefore are a perfect tool to be used within a microservice cloud architecture. The usage of volumes and environment variables allow the environments (e.g. Kubernetes) to inject work data and configuration. Using these tools we can solve many problem with satateless containers that allow to easily scale applications.