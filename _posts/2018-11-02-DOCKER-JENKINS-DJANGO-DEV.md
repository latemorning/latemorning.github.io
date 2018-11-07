---
layout:   post
title:    도커+젠킨스+Nginx+uWSGI, Django 개발환경
author:   harry
tags:     [post, dev, docker, jenkins, Nginx, uWSGI, Django]
comments: false
---
<!-- Start Writing Below in Markdown -->

우분투 Ubuntu 18.04.1 LTS 에서 Docker 기반 설치

#### Ubuntu 셋팅
서버 머신에 우분투를 설치하거나 AWS를 이용하여 Ubuntu 설치
- ###### 타임 존 설정
Asia/Seoul 타임존 설정, 아래 Docker Run에 필요함
      sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
- ###### Docker 설치
연동에 필요한 프로그램들은 Docker를 이용하여 설치
      sudo snap install docker

#### 젠킨스 설치
- ##### Docker 젠킨스 volume 생성
      sudo docker volume create jenkinsvol
- ##### 젠킨스 Docker 이미지 다운로드
      sudo docker pull jenkins/jenkins:lts
- ##### 젠킨스 Docker 실행
```
   sudo docker run --name jenkins -d --restart always -p 8080:8080 -p 50000:50000 -v jenkinsvol:/var/jenkins_home -v /etc/localtime:/etc/localtime:ro jenkins/jenkins:lts
```
8080 포트로 접속 후 인증키 입력, 관리자 비번설정, 플러그인 설치 진행 자세한 설명 생략합니다.
인증키 입력 시 Docker 컨테이너에 접속은 <mark>sudo docker exec -it jenkins /bin/bash</mark>로 접속

- #### 젠킨스 셋팅
  젠킨스가 하는 역할은 git에서 최신 소스를 받아 Publish over SSH 에서 설정한 서버(Docker Host)의 shell을 실행한다.
  - ##### Jenkins 관리
    - ###### Global Tool Configuration
      Git 관련된 설정을 함
    - ###### 플러그인 관리
      Publish Over SSH 설치
    - ###### 시스템 설정
      Publish over SSH 에서 접속할 서버 추가  

  - ##### 새로운 Item
    1. Item 이름 입력
    2. Freestyle project 선택 -> OK 클릭
    3. 소스 코드 관리 Git 선택
    4. Repository URL 입력
    5. Credentials Add 클릭 -> git id/pass 정보로 key 생성
    6. Credentials 위에서 생성한 key 선택
    7. 빌드 유발 - GitHub hook trigger for GITScm polling 체크

- #### Docker Host shell
  - ###### Docker Host shell
  /home/ubuntu/docker/django-uwsgi-nginx
  ```shell
  #!/bin/sh
  # docker-compose로 기동한 Nginx 다운
  sudo docker-compose down
  # Docker Host 에서 기존 개발 소스 삭제
  sudo /bin/rm -rf /home/ubuntu/docker/django-uwsgi-nginx/sichuan
  # jenkins 빌드에서 다운 받은 최신 소스를 Docker Host 소스 폴더에 복사
  sudo /bin/cp -vfr /var/snap/docker/common/var-lib-docker/volumes/jenkinsvol/_data/workspace/sichuan /home/ubuntu/docker/django-uwsgi-nginx/
  # 위에서 받은 소스 중 git 관련 파일 삭제
  sudo /bin/rm -rf /home/ubuntu/docker/django-uwsgi-nginx/sichuan/.git
  # 위에서 받은 소스 소유권 변경
  sudo /bin/chown ubuntu:ubuntu -R /home/ubuntu/docker/django-uwsgi-nginx/sichuan
  # docker-compose로 Docker 빌드, Nginx 실행
  sudo docker-compose up -d --build
  ```

  - ###### docker-compose.yml
  특별한 설정은 없고 80포트 사용하도록 설정
  ```yml
  version: '3'
  services:
      nginx:
          build:
              context: .
              dockerfile: ./Dockerfile
          ports:
              - "80:80"
  ```

  - ###### Dockerfile
    <pre><code>
    FROM ubuntu:16.04

    MAINTAINER Dockerfiles

    # 필수 패키지를 설치하고 완료되면 apt 패키지 cache 제거

    RUN apt-get update && \
        apt-get upgrade -y && \ 	
        apt-get install -y \
    	git \
    	python3 \
    	python3-dev \
    	python3-setuptools \
    	python3-pip \
    	nginx \
    	supervisor \
            libmysqlclient-dev \
    	sqlite3 && \
    	pip3 install -U pip setuptools && \
       rm -rf /var/lib/apt/lists/*

    # uwsgi, mysqlclient 설치
    RUN pip3 install uwsgi mysqlclient

    # 모든 configfiles 설정
    RUN echo "daemon off;" >> /etc/nginx/nginx.conf
    COPY sichuan_nginx_app.conf /etc/nginx/sites-available/default
    COPY supervisor-app.conf /etc/supervisor/conf.d/

    # COPY requirements.txt and RUN pip install BEFORE adding the rest of your code, this will cause Docker's caching mechanism
    # to prevent re-installing (all your) dependencies when you made a change a line or two in your app.

    COPY app/requirements.txt /home/docker/code/sichuan/
    RUN pip3 install -r /home/docker/code/sichuan/requirements.txt

    # 개발 소스 추가
    COPY sichuan/ /home/docker/code/sichuan/

    # supervisor로 명령 실행
    CMD ["supervisord", "-n"]  
    </code></pre>
  - ###### sichuan_nginx_app.conf
  Nginx와 uWSGI 연동
    <pre><code>
    # nginx-app.conf

    # nginx 연동 방법, 파일 소켓 방식과 웹 포트 방식이 있음
    upstream django {
        server unix:///home/docker/code/sichuan/sichuan.sock; # 파일 소켓
        # server 127.0.0.1:8001; # 웹 포트
    }

    # 서버 구성
    server {
        # 사용할 port
        listen      80;

        # 도메인 이름, 도메인이 없으면 서버의 ip
        server_name dev.kkul-i.xyz;
        charset     utf-8;

        # max upload size
        client_max_body_size 75M;   # adjust to taste

        location = /favicon.ico { access_log off; log_not_found off; }

        # Django media
        location /media  {
            alias /home/docker/code/sichuan/media;  # your Django project's media     files - amend as required
        }

        location /static {
            alias /home/docker/code/sichuan/static; # your Django project's static     files - amend as required
        }

        # Finally, send all non-media requests to the Django server.
        location / {
            uwsgi_pass  django;
            include     /home/docker/code/sichuan/uwsgi_params; # the uwsgi_params     file you installed
        }
    }
    </code></pre>
  - ###### uwsgi_params
    해당 파일은 변경하지 말고 그대로 사용
    <pre><code>  
    uwsgi_param  QUERY_STRING       $query_string;
    uwsgi_param  REQUEST_METHOD     $request_method;
    uwsgi_param  CONTENT_TYPE       $content_type;
    uwsgi_param  CONTENT_LENGTH     $content_length;

    uwsgi_param  REQUEST_URI        $request_uri;
    uwsgi_param  PATH_INFO          $document_uri;
    uwsgi_param  DOCUMENT_ROOT      $document_root;
    uwsgi_param  SERVER_PROTOCOL    $server_protocol;
    uwsgi_param  HTTPS              $https if_not_empty;

    uwsgi_param  REMOTE_ADDR        $remote_addr;
    uwsgi_param  REMOTE_PORT        $remote_port;
    uwsgi_param  SERVER_PORT        $server_port;
    uwsgi_param  SERVER_NAME        $server_name;
    </code></pre>

  - ###### supervisor-app.conf
    실행할 명령어 정의, uwsgi, Nginx 실행
    <pre><code>  
    [program:app-uwsgi]
    command = /usr/local/bin/uwsgi --ini /home/docker/code/sichuan/sichuan_uwsgi_dev.ini

    [program:nginx-app]
    command = /usr/sbin/nginx
    </code></pre>

  - ###### sichuan_uwsgi_dev.ini
    uwsgi 설정
    <pre><code>  
    [uwsgi]
    # 기본 로드 되는 설정
    ini = :base

    # 구성 파일 위치, uwsgi가 실행되면 sichuan.sock이 생성됨
    socket = /home/docker/code/sichuan/sichuan.sock
    master = true
    processes = 4

    [dev]
    ini = :base
    # socket (uwsgi) is not the same as http, nor http-socket
    socket = :8001

    [local]
    ini = :base
    http = :8000
    # set the virtual env to use
    #home=/Users/you/envs/env

    [base]
    # chdir to the folder of this config file, plus app/website
    chdir = /home/docker/code/sichuan
    # load the module from wsgi.py, it is a python path from
    # the directory above.
    module=sichuan.wsgi:application
    # 소켓에 연결 할 수 있도록 권한 변경
    chmod-socket=666
    vacuum=true
    </code></pre>

  - #### 소스 github 위치
