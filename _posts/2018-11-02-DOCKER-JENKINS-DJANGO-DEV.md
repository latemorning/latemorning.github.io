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
- ###### 타임존 변경
      sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
- ###### Docker 설치
      sudo snap install docker

#### 젠킨스 설치
- ##### Docker 젠킨스 volume 생성
      sudo docker volume create jenkinsvol
- ##### 젠킨스 이미지 다운
      sudo docker pull jenkins/jenkins:lts
- ##### 젠킨스 실행
```
   sudo docker run --name jenkins -d --restart always -p 8080:8080 -p 50000:50000 -v jenkinsvol:/var/jenkins_home -v /etc/localtime:/etc/localtime:ro jenkins/jenkins:lts
```
8080 포트로 접속 후 인증키 입력, 관리자 비번설정, 플러그인 설치 진행 자세한 설명 생략
Docker 컨테이너 shell접속은 <mark>sudo docker exec -it jenkins /bin/bash</mark> 로 접속

- ##### Jenkins 관리
  - ###### Global Tool Configuration
    - Git 설정
  - ###### 플러그인 관리
    - Publish Over SSH 설치
  - ###### 시스템 설정
    - Publish over SSH 서버 추가  

- ##### 새로운 Item
  1. Item 이름 입력
  2. Freestyle project 선택 -> OK 클릭
  3. 소스 코드 관리 Git 선택
  4. Repository URL 입력
  5. Credentials Add 클릭 -> git id/pass 정보로 key 생성
  6. Credentials 위에서 생성한 key 선택
  7. 빌드 유발 - GitHub hook trigger for GITScm polling 체크

  젠킨스가 하는 역할은 git 에서 최신 소스를 받아서 Publish over SSH 에서 설정한 서버의 shell을 실행한다.
