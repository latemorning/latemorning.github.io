---
layout:   post
title:    윈도우 Docker MariaDB 설치
author:   harry
tags:     [Docker, MariaDB]
comments: true
published : true
---

## 윈도우 Docker Toolbox에 MariaDB 설치하기
Docker Toolbox 설치방법은 [링크](https://steemit.com/kr/@mystarlight/docker) 참조
Docker Toolbox를 설치하면 아래와 같은 3개의 아이콘이 생성됩니다.
![img_01](/images/2019-03-07-Docker-MariaDB-install/img_01.png)

Kitematic 실행합니다.
![img_02](/images/2019-03-07-Docker-MariaDB-install/img_02.png)

mariadb라고 검색을 하면 검색 결과가 출력됩니다. 이중 official이라고 표시된 것이 공식 이미지입니다.
CREATE 버튼 왼쪽에…. 눌러보면 설명을 볼 수 있습니다. 우선 CREATE 버튼을 눌러서 이미지를 다운로드 합니다.
![img_03](/images/2019-03-07-Docker-MariaDB-install/img_03.png)

저는 Kitematic 보다 터미널이 편해서 아래부터는 터미널에서 작업하겠습니다.
방금 다운받은 mariadb 이미지가 보입니다. [여기](https://hub.docker.com/_/mariadb)에서 mariadb에 대한 설명을 볼 수 있습니다.
```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
mariadb             latest              233f064f3a7e        5 days ago          368MB
ubuntu-upstart      latest              b28219773b9b        3 years ago         253MB
```

#### 볼륨 생성
볼륨은 mariadb 컨테이너에 생성된 파일들을 HOST PC에도 똑같이 만들어 줍니다.
도커 서버가 삭제되면 그동안 생성되었던 DB 자료들도 같이 삭제되므로 꼭 만들어야 합니다.
다음에 다시 컨테이너를 생성하게 되면 HOST PC에 있던 데이터도 컨테이너에 같이 생성됩니다.
```
$ docker volume create mariadb_vol
mariadb_vol
```
잘 생성되었는지 확인
```
$ docker volume inspect mariadb_vol
[
    {
        "CreatedAt": "2019-03-07T06:31:50Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/mnt/sda1/var/lib/docker/volumes/mariadb_vol/_data",
        "Name": "mariadb_vol",
        "Options": {},
        "Scope": "local"
    }
]
```
HOST PC 경로가 나오네요. Docker Toolbox는 Oracle VirtualBox에서 실행되는 거라
![img_04](/images/2019-03-07-Docker-MariaDB-install/img_04.png)

#### MariaDB 실행
```
docker run --name mariadb -d -v mariadb_vol:/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=aRBeJQVFmfQ7 mariadb
```

| 옵션    | 설명                           |
|---------|--------------------------------|
| --name  | 컨테이너 이름                  |
| -d      | 백그라운드 실행                |
|  -v     | HOST PC 와 파일 공유           |
| -p      | HOST PC 와 포트 연동           |
| -e      | MariaDB 실행에 필요한 옵션값들 |
| mariadb | 실행할 이미지 이름             |

혹시 실행했는데 중복되는 컨테이너 이름이 있다고 하면 아래처럼 삭제합니다.
Kitematic 에서 이미지 다운로드 받으면서 자동으로 실행시킨 거 같습니다.
```
$ docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                         PORTS               NAMES
82e63f1a0deb        mariadb:latest          "docker-entrypoint.s…"   About an hour ago   Exited (1) About an hour ago                       mariadb
61234127aa34        ubuntu-upstart:latest   "/sbin/init"             3 weeks ago         Exited (137) 3 weeks ago                           ubuntu-upstart

$ docker rm mariadb
mariadb
```
다시 실행 하면 STATUS가 Up이라고 표시되네요. 현재 실행 중입니다. 아까 열어놓았던 Kitematic 화면에 로그가 표시되네요
```
$ docker run --name mariadb -d -v mariadb_vol:/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=aRBeJQVFmfQ7 mariadb
2bc8456cc43ba462b3034687cfcdfbf3e181f0e6bb297f61126864c530a06bc3

$ docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                     PORTS                    NAMES
2bc8456cc43b        mariadb                 "docker-entrypoint.s…"   26 seconds ago      Up 22 seconds              0.0.0.0:3306->3306/tcp   mariadb
61234127aa34        ubuntu-upstart:latest   "/sbin/init"             3 weeks ago         Exited (137) 3 weeks ago                            ubuntu-upstart
```

#### 접속
접속은 mysql 접속 가능한 클라이언트나 phpmyadmin 같은 웹 툴을 설치해서 확인할 수 있습니다.
phpmyadmin을 설치해 보겠습니다.
[도커허브](https://hub.docker.com/)에서 phpmyadmin 으로 검색합니다.
이 중에서 맨 위에 있는 이미지가 가장 인기 있는 거 같네요. 클릭해서 들어갑니다.
![img_05](/images/2019-03-07-Docker-MariaDB-install/img_05.png)

오른쪽 중간쯤에 이미지 다운로드 방법이 있습니다. 복사합니다.
![img_06](/images/2019-03-07-Docker-MariaDB-install/img_06.png)

이미지가 다운로드 됐습니다.
```
$ docker pull phpmyadmin/phpmyadmin
Using default tag: latest
latest: Pulling from phpmyadmin/phpmyadmin
cd784148e348: Pull complete
d207535cd57f: Pull complete
1167ab95319c: Pull complete
bff34bff7f50: Pull complete
d09fbf86b8ee: Pull complete
1cfe903e31f6: Pull complete
88d3f120681c: Pull complete
9077db937f31: Pull complete
8bb3fe9faa6e: Pull complete
17142adf57d1: Pull complete
36147ae6ebdd: Pull complete
1056b4fffa1d: Pull complete
b673c9eeddc3: Pull complete
293a885a51a7: Pull complete
d8537b27d5ad: Pull complete
e37128d94b06: Pull complete
a83c7859d09a: Pull complete
Digest: sha256:8efb1f7047d8d6c9d5061f43bb27c9b63e8cd6bd7ed6cb4ccd2a17497ae21c1f
Status: Downloaded newer image for phpmyadmin/phpmyadmin:latest

$ docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
mariadb                 latest              233f064f3a7e        5 days ago          368MB
phpmyadmin/phpmyadmin   latest              c6ba363e7c9b        5 weeks ago         166MB
ubuntu-upstart          latest              b28219773b9b        3 years ago         253MB
```

이미지 실행
phpmyadmin은 저장되는 데이터가 없는 것 같아 볼륨은 만들지 않았습니다.
```
$ docker run --name phpmyadmin -d --link mariadb:db -p 8087:80 phpmyadmin/phpmyadmin
f66b61fc7817289457707f0ffb37d753db9e1ea297a7e08958d30bac10e598c0
```

| 옵션   | 설명                                |
|--------|-------------------------------------|
| --link | 다른 컨테이너와 연동(mariadb와 연동)|

Docker Toolbox는 Oracle VM VirtualBox 안에서 돌아가기 때문에 로컬 PC와 VirtualBox 안에 HOST 간 포트 포워딩을 해줘야 합니다.

>로컬PC:8087 > VirtualBox HOST:8087 > phpmyadmin 컨테이너:80

제가 제대로 이해를 하는 것인지 모르겠지만 HOST:8087과 phpmyadmin 컨테이너:80은 컨테이너 실행할 때 연결했고 로컬 PC:8087 > HOST:8087을 연결해야 합니다.
설정 > 네트워크 > 포트 포워딩 > +버튼 -> 포트 추가합니다.
![img_07](/images/2019-03-07-Docker-MariaDB-install/img_07.png)

이제 브라우저 에서 localhost:8087 로 접속합니다.
![img_08](/images/2019-03-07-Docker-MariaDB-install/img_08.png)

드디어 나옵니다.
사용자 명 : root, 암호 : mariadb 실행할 때 -e 옵션으로 설정한 값
![img_09](/images/2019-03-07-Docker-MariaDB-install/img_09.png)

끝.
