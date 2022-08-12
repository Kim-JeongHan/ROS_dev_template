# Docker
## 1. Requirment : nvidia-docker<br>
 - 설치
```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```
```
sudo apt update
```
```
sudo apt install -y nvidia-docker2
```
```
sudo systemctl restart docker
```
<br>

## 2. image 실행
완성된 이미지는 아래의 경로에 별도로 저장중
smb://roboetech.local/catkin_ws/image/roboe_docker_image_220811_v1.tar

- tar파일에서 이미지 추출
```
sudo docker load < roboe_image_220811_v1.tar
```
- 기본 실행 명령
```
sh run-ubuntu-roboe.sh
```
- 실행중인 컨테이너 접속
```
~$ docker exec -it {container_name} bash
~$ docker exec -it {container_name} terminator
```
- 실행중인 컨테이너 종료
```
(container)~$ exit or ctrl+d
```
   ### terminator 단축키<br>
    - 수직분할 : Ctrl + Shift + e
    - 수평분할 : Ctrl + Shift + o
    - 현재창닫기 : Ctrl + Shift + w

## 3. (참고) Dockerfile 
ROS noetic / Ubuntu 20.04 이미지 기반<br>
\+ python3.6 설치 <br>
\+ ROS catkin_ws 생성 및 초기화<br>
\+ roboenet clone & install<br>
\+ doosan-robot clone & install<br>
\+ cuda==11.3, cudnn==8.2.1 install, tensorflow==2.6.0<br>

- [Build Command]<br>
```
$ docker build -t ubuntu:roboe . 
```
* 해당 Dockerfile을 build할때 git private repository를 clone하므로, <br>
이를 위해서 동일 경로에 id_rsa(개인 ssh private key) 파일이 필요하다. <br>
(roboenet, SDFGen, v-hacd repository에 대한 접근권한도 필요)<br>
<br>