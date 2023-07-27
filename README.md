# ROS_dev_template


# TL;DR

Build a new dev image
```
export UID=$(id -u) export GID=$(id -g); docker compose build
```

start a dev container

```
docker compose  run dev
```

#### setting env
If you want to rename the folder ("my package"), you need to rename the folder and write the name in the REPO in the "[.env](https://github.com/Kim-JeongHan/ROS_dev_template/blob/master/.env)".


#### Volume mapping
While the container itself by default is not persistent, several host directories
are mapped into the container including
- repository source code
- ssh keys
- git configuration
- host credentials
- X11 connection

#### git

you can use gitconfig within the container, with the same host user


## docker compose v2
Taken from https://docs.docker.com/compose/cli-command/#install-on-linux


# Alias

While developing a tool on top of another tool can come with challenges,
some may prefer to at least have some simple aliases to reduce the typing boilerplate.
```shell
alias builddev="export UID=$(id -u) export GID=$(id -g); docker compose build"
alias rundev="docker compose run development"
```

# References

I referenced several repositories in my development environment configuration.
- [griswaldbrooks/development-container](https://github.com/griswaldbrooks/development-container/tree/main)
- [PickNikRobotics/ros_testing_templates](https://github.com/PickNikRobotics/ros_testing_templates)
- [sea-bass/turtlebot3_behavior_demos](https://github.com/sea-bass/turtlebot3_behavior_demos)
