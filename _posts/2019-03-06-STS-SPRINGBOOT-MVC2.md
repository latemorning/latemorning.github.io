---
layout:   post
title:    STS에서 Spring Boot 웹 프로젝트 시작하기 2
author:   harry
tags:     [STS, Spring Boot, Web, MVC]
comments: true
published : true
---

## STS에서 Spring Boot 웹 프로젝트 시작하기 2
1편에서 기본 스프링부트 웹 프로젝트를 생성했고 정적 콘텐츠 index.html을 실행해보았다
이번에는 MVC 구성을 하고 JSP를 사용할 수 있도록 설정해본다.

### application.propeties의 설정
application.properties 파일을 연다. 빈 파일이 열릴 것이다
아래와 같이 MVC 속성을 추가한다.
```
spring.mvc.view.prefix=/WEB-INF/views/
spring.mvc.view.suffix=.jsp
```
spring.mvc.view. 까지 입력해보면 나머지 자동완성이 뜨는걸 볼 수 있다
스프링 부트는 @EnableAutoConfiguration 을 통하여 스프링의 모든 설정을 자동으로 하고
필요한 설정은 application.properties에 새롭게 정의하는 값으로 오버라이딩 된다.
더 자세한 사항은 마지막 링크 참조


### Controller 생성
스프링부트는 컴포넌트 스캔을 할 때 메인 클래스 위치를 기준으로 그 하위 패키지를 스캔한다(다른 위치 설정도 가능)
com.pet.aki.cmm 패키지에 공통기능을 만들기로 정하였고, 컨트롤러 클래스는 web 패키지에 작성하기로 하고 com.pet.aki.cmm.web 패키지에 Controller 작성함
```java
package com.pet.aki.cmm.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HelloWorldController {

	@RequestMapping("/")
	public String index() {
		System.out.println("@RequestMapping(\"/\")");
		return "index";
	}

	@RequestMapping("/hello")
	public String helloWorld() {
		System.out.println("@RequestMapping(\"/hello\")");
		return "/com/pet/aki/cmm/hello";
	}
}
```


### 서버 실행
boot Application을 실행하고 접속해본다. (localhost:8080/)
로그에 컨트롤러 메시지는 찍히는데 404 에러가 발생

이번에는 gradle의 bootRun으로 톰켓실행 bootRun을 더블클릭
아래 화면은 이클립스 단축키 Ctrl + 3 누른 후 텍스트 박스에 gradle 이라고 입력하고 Gradle Tasks 선택하면 됨
![img_07](/images/2019-03-06-STS-SPRINGBOOT-MVC/img_07.png)
그래도 똑같이 404에러 발생

이번에는 build.gradle 파일을 열어서 boot의 톰캣을 주석 처리하고 아래 2라인을 추가(외부 톰캣 사용)
```
compile('javax.servlet:jstl')
compile("org.apache.tomcat.embed:tomcat-embed-jasper")
```
전체 내용
```
dependencies {
  implementation 'org.springframework.boot:spring-boot-starter-web'
  //providedRuntime 'org.springframework.boot:spring-boot-starter-tomcat'
  testImplementation 'org.springframework.boot:spring-boot-starter-test'
  compile('javax.servlet:jstl')
  compile("org.apache.tomcat.embed:tomcat-embed-jasper")
}
```
boot Application 실행
똑같다.

마지막으로 gradle의 bootRun으로 톰캣을 실행함
잘된다.

결론은 외부 톰캣을 사용하고 gradle의 bootRun을 실행해야 함
최근에 나온 boot는 JSP를 지원하지 않는다고 합니다.

### 참고
출처: https://yonguri.tistory.com/entry/스프링부트-SpringBoot-개발환경-구성-2-MVC-환경구성?category=359079 [Yorath's 블로그]
