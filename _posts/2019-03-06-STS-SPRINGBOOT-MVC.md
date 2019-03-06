---
layout:   post
title:    STS에서 Spring Boot 웹 프로젝트 시작하기
author:   harry
tags:     [STS, Spring Boot, Web]
comments: true
published : true
---

### STS 다운로드 & 설치
다음 [링크](https://spring.io/tools)에서 다운로드 (현재 4.1.2 최신)
적당한 위치에 압축 해제하면 설치가 완료된다.

### 프로젝트 생성
스프링 부트를 사용하여 웹프로젝트 생성 gradle을 사용하기로 한다.
단축키 Ctrl + N,
Spring Boot -> Spring Starter Project 선택
![img_01](/images/2019-03-06-STS-SPRINGBOOT-MVC/img_01.png)

다음 정보들은 자신의 상황에 맞게 적당히 수정한다.
Name : 프로젝트 이름
Type : 빌드툴 Gradle3 사용
Packaging : 웹프로젝트 이므로 War 선택
Group : 알아서 수정
Description : 설명
Package : 패키지 경로 지정 Group 하고 맞춰서 지정함
![img_02](/images/2019-03-06-STS-SPRINGBOOT-MVC/img_02.png)

프로젝트 Dependencies 선택
우선은 Web -> Web 만 선택한다.
![img_03](/images/2019-03-06-STS-SPRINGBOOT-MVC/img_03.png)

아래와 같은 구조의 프로젝트가 생성된다.
![img_04](/images/2019-03-06-STS-SPRINGBOOT-MVC/img_04.png)
스프링부트는 html, css, js, image 등 정적 웹 라이브러리를
src > main > resources > static 아래서 관리한다.


AkiApplication.java 파일에 있는 main 클래스를 실행시키면 자체 톰켓이 동작한다.
![img_05](/images/2019-03-06-STS-SPRINGBOOT-MVC/img_05.png)
로그를 보면 톰켓버전, 포트 정보를 알수 있다
스프링부트를 이용하여 프로젝트를 생성하면 기존에 직접 관리하던 톰켓 설정과
web.xml 파일등은 스프링부트 내부모듈에 의해서 구동시 자동설정된다.

브라우저에 localhost:8080 으로 입력해본다.
![img_06](/images/2019-03-06-STS-SPRINGBOOT-MVC/img_06.png)
친숙한 404에러 그래도 뭔가 돌아가는거 같다.

이제 static 폴더에 index.html 파일을 만들고 어플리케이션을 재구동한다.
'Hello, World' 를 화면에 출력해보자
