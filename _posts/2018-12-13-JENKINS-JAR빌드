---
layout:   post
title:    jenkins jar 빌드
author:   harry
tags:     [jenkins, jar]
comments: false
---
<!-- Start Writing Below in Markdown -->

# jenkins jar 빌드

## Item 생성 및 설정
### 1) New Item
프로젝트명 입력, 스타일 선택
![](/images/jenkins/jenkins_02.png "jenkins 빌드 생성")<br/>

### 2) 소스 코드 관리
SVN 저장소 url과 Add 버튼을 눌러서 계정정보 입력
![](/images/jenkins/jenkins_05.png "jenkins 빌드 생성")<br/>

### 3) build 설정
Invoke Gradle script 선택
![](/images/jenkins/jenkins_06.png "jenkins 빌드 생성")<br/>

jenkins 관리에서 설치한 gradle을 선택하고 Task 입력<br/>
여기까지 설정하고 빌드를 실행시키면 최종 jar파일이 생성됨
![](/images/jenkins/jenkins_07.png "jenkins 빌드 생성")<br/>

여기서 부터는 개인적인 환경이라 설명이 부실함...<br/>
생성된 jar 파일을 원하는 위치로 복사하는 step<br/>
원격서버에서 cd docker 실행후 integration_shell.sh를 실행시킴 <br/>
Add build step 빌드 추가 - Over SSH 선택<br/>
Publish Over SSH 플러그인을 먼저 설치해야 해당 메뉴가 나옴<br/>
Over SSH는 원격의 shell을 실행할때 사용함
![](/images/jenkins/jenkins_08.png "jenkins 빌드 생성")<br/>

![](/images/jenkins/jenkins_09.png "jenkins 빌드 생성")<br/>
