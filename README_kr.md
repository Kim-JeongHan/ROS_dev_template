# ROS_dev_template

# 커스터마이징 및 사용방법

### build

처음 이미지를 빌드할때는 docker compose build를 사용해서 build하는 것이 좋다.
```
export UID=$(id -u) export GID=$(id -g); docker compose build
```
또한 만약 dockerfile에 수정사항이 생겼거나, docker-compose에 수정사항이 생긴경우 똑같은 방식으로 다시build해 주면된다.

이때는 기존이미지가 <none>으로 바뀌고, 새로운 이미지가 update된다.

#### <none>이미지 삭제 방법

만약 <none>과 관련된 container가 실행중이라면 종료시켜주고 컨테이너를 삭제시켜준다.


```
docker rm $(docker ps --filter status=exited -q)
```
그 후 <none>이미지를 일괄 삭제한다.
```
docker images -f "dangling=true" -q
```

### .env파일 : package이름 custom과 ROS version custom

my_pacakge를 자신이 새롭게 만든 패키지로 대체하고 싶은 경우가 있다.
이때는 my_package를 본인의 package로 대체한 후 [.env](https://github.com/Kim-JeongHan/ROS_dev_template/blob/master/.env)파일에서 'REPO'를 수정해주면된다.

또한 ROS version을 foxy나, rolling을 사용하고 싶은 경우 ros_version을 바꾸어준다.

```
# Default environment variables for Docker Compose file
REPO=<custom_package>
ROS_DISTRO=<ros_version>
```
### Volume mapping
volume에 mapping해놓은 리스트이다. 따로 volume mapping을 하고 싶다면 추가하거나 바꿀수 있다.

- repository source code
- ssh keys
- git configuration
- host credentials
- X11 connection
-
#### git

gitconfig를 volume mapping해놓았기 때문에 local gitconfig환경을 docker container안에서 사용할 수 있다.

## docker compose v2

다음 링크에서 docker compose v2를 설치 할 수 있다.

https://docs.docker.com/compose/cli-command/#install-on-linux


# Alias

alias 설정을 해서 편하게 docker build를 실행할 수 있다. 이는 vscode dev와 무관하게 작동시킬 수 있다.
```shell
alias builddev="export UID=$(id -u) export GID=$(id -g); docker compose build"
alias rundev="docker compose run dev"
```

# References

다음 github링크들을 참고해서 구성했다. 더 자세한 내용은 아래 레퍼런스를 참고하면 더 자세한 내용을 알 수 있다.
- [griswaldbrooks/development-container](https://github.com/griswaldbrooks/development-container/tree/main)
- [PickNikRobotics/ros_testing_templates](https://github.com/PickNikRobotics/ros_testing_templates)
- [sea-bass/turtlebot3_behavior_demos](https://github.com/sea-bass/turtlebot3_behavior_demos)
