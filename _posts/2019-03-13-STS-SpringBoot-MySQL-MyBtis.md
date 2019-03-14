---
layout:   post
title:    STS에서 Spring Boot 웹 MyBatis, MySQL 연동
author:   harry
tags:     [Spring Boot, MyBatis, MySQL, MariaDB]
comments: true
published : true
---

## STS에서 Spring Boot 웹 MyBatis, MySQL 연동

### 새 프로젝트 생성

#### 의존성
이전에 했던 MVC 프레임 워크는 WEB 의존성만 선택했는데 이번에는 WEB, MyBatis, MySQL
3가지를 선택
![img_01](/images/2019-03-13-STS-SpringBoot-MySQL-MyBtis/img_01.png)

이전에 생성했던 MVC 프레임 워크와 차이점은 build.gradle dependencies 부분에
MyBtis와 MYSQL 관련 dependenci 2개가 더 추가됐습니다.
```
implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:2.0.0'
runtimeOnly 'mysql:mysql-connector-java'
```
그래서 2줄을 복사하여 기존 프로젝트에 추가하고 새로 생성한 프로젝트는 close 하겠습니다.

이전 프로젝트에 MyBtis와 MYSQL 관련 dependenci를 추가한 모습
```
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    //providedRuntime 'org.springframework.boot:spring-boot-starter-tomcat'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    compile('javax.servlet:jstl')
    compile("org.apache.tomcat.embed:tomcat-embed-jasper")
    implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:2.0.0'
    runtimeOnly 'mysql:mysql-connector-java'
}
```

#### MariaDB 준비
이전에 내 PC에 Docker Toolbox를 설치하고 MariaDB와 phpmyadmin을 설치해봤습니다.
이전 내용을 다시 참조하여 MariaDB와 phpmyadmin을 구동합니다.
참고로 MariaDB와 MySQL은 그냥 똑같다고 생각하시면 됩니다.

#### 데이터베이스 및 사용자 생성
MariaDB를 사용하려면 사용자와 데이터베이스를 생성해야 합니다.
phpMyAdmin에 접속해서 데이터베이스 탭을 클릭합니다.
기본적으로 information_schema, mysql, performance_schema 3개의 데이터베이스가 있고
phpmyadmin 데이터베이스는 phpMyAdmin이 생성한 데이터베이스입니다.
![img_02](/images/2019-03-13-STS-SpringBoot-MySQL-MyBtis/img_02.png)

#### 데이터베이스 생성
간단합니다. 데이터베이스 이름, 캐릭터 셋 입력하고 만들기 버튼 클릭
캐릭터 셋에 대한 설명은 생략
![img_05](/images/2019-03-13-STS-SpringBoot-MySQL-MyBtis/img_05.png)

#### 사용자 생성
사용자 계정 탭을 눌러보면 다음과 같이 root 사용자가 존재합니다.
호스트 명에 % 는 어느 위치에서든 접속 가능하다는 걸 나타내고 localhost는 로컬 pc에서만 접속 가능하다는 의미입니다.
![img_03](/images/2019-03-13-STS-SpringBoot-MySQL-MyBtis/img_03.png)

사용자를 추가해보겠습니다. [사용자 추가] 링크를 클릭합니다.
저는 아래처럼 입력하고 생성했습니다. password >Hn+Exs(F.7:
화면 우측 맨 아래 실행 버튼을 누릅니다.
![img_04](/images/2019-03-13-STS-SpringBoot-MySQL-MyBtis/img_04.png)
아래 스크립트는 위 화면에서 사용자를 추가한 액션에 대한 스크립트입니다. 긁어서 SQL 탭에서 실행하면 같은 결과가 나타납니다.
```
CREATE USER 'aki'@'localhost' IDENTIFIED VIA mysql_native_password USING '***';GRANT USAGE ON *.* TO 'aki'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;

-- % 접속권한 주기, 나중에 실행
CREATE USER 'aki'@'%' IDENTIFIED VIA mysql_native_password USING '***'; GRANT USAGE ON *.* TO 'aki'@'%' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0; GRANT ALL PRIVILEGES ON `aki`.* TO 'aki'@'%' WITH GRANT OPTION;
```
첫 번째 줄은 localhost 권한이고 두 번째 줄은 % 권한 부여

#### 사용자에게 DB 사용 권한 부여
aki 사용자와 aki 데이터베이스를 생성했으면 aki 사용자가 aki 데이터베이스를 사용하도록 권한을 부여합니다. 사용자 목록에서 aki 사용자 권한 수정을 클릭합니다.
![img_06](/images/2019-03-13-STS-SpringBoot-MySQL-MyBtis/img_06.png)

데이터베이스 클릭, aki 데이터베이스 클릭, 실행 클릭
![img_07](/images/2019-03-13-STS-SpringBoot-MySQL-MyBtis/img_07.png)

모두 체크 클릭하고 실행
![img_08](/images/2019-03-13-STS-SpringBoot-MySQL-MyBtis/img_08.png)
```
GRANT ALL PRIVILEGES ON `aki`.* TO 'aki'@'localhost' WITH GRANT OPTION;
```

#### aki로 접속
localhost로 접속하는게 아니라 도커 네트워크의 IP로 접속을 하려 하면 접속이 되지 않습니다.
그럴 때 aki 계정에 % 접속 권한을 줘야 합니다. 사용자 추가 부분 2번째 줄이 % 접속 권한 생성 스크립트입니다. 복사해서 SQL 탭에서 실행하면 % 사용자가 생성되고 권한까지 부여됩니다.
접속했더니 아래와 같이 aki 데이터베이스와 기본 스키마가 보입니다.
![img_09](/images/2019-03-13-STS-SpringBoot-MySQL-MyBtis/img_09.png)
phpMyAdmin 스키마가 없다고 경고가 뜨네요. root로 접속해서 phpmyadmin 데이터베이스에 대한 권한도 줘야겠습니다.

여기까지 MariaDB 설정입니다.

#### DB 정보 설정
DB정보를 application.properties 에 설정합니다.
```
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/aki
spring.datasource.username=aki
spring.datasource.password=>Hn+Exs(F.7:
```

#### 테이블 생성
phpmyadmin SQL 탭에 붙여넣고 실행
```sql
CREATE TABLE `member` (
    `code` INT(11) NOT NULL AUTO_INCREMENT ,
    `name` VARCHAR(255) NULL DEFAULT NULL ,
    `team` VARCHAR(255) NULL DEFAULT NULL ,
    PRIMARY KEY (`code`)
) ENGINE = InnoDB CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT = 'member test';

INSERT INTO member(name, team) VALUES('박지성', '맨체스터유나이티드');
INSERT INTO member(name, team) VALUES('기성용', '스완지시티');
INSERT INTO member(name, team) VALUES('손홍민', '토트넘');
```

#### 모델
member 테이블을 표현합니다.
```java
package com.pet.aki.cmm.model;

public class MemberVO {

	private String code = "";
	private String name = "";
	private String team = "";

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getTeam() {
		return team;
	}

	public void setTeam(String team) {
		this.team = team;
	}

}
```

#### Mapper 인터페이스
Mapper XML 파일과 1:1 매핑 인터페이스 파일 하나로 쿼리와 매핑됩니다.
```java
package com.pet.aki.cmm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.pet.aki.cmm.model.MemberVO;

@Mapper
public interface MemberMapper {

	public List<MemberVO> selectMemberList();

	public MemberVO selectMemberById(Long id);

	public void insertMember(MemberVO memberVO);
}
```

#### Mapper XML
쿼리를 작성합니다. 위치는 resources 폴더에 Mapper 인터페이스와 같은 경로에 생성합니다.
src/main/resources/com.pet.aki.cmm.mapper
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="com.pet.aki.cmm.mapper.MemberMapper">

    <select id="selectMemberList" parameterType="com.pet.aki.cmm.model.MemberVO" resultType="com.pet.aki.cmm.model.MemberVO">
        select * from member
    </select>

    <select id="selectMemberById" parameterType="java.lang.Long" resultType="com.pet.aki.cmm.model.MemberVO">
        SELECT
                code
              , name
              , team
          FROM
                member
         WHERE
                code = #{id}  
    </select>

    <insert id="insertMember">
    	insert into
    	        member(
    	                name
    	              , team
    	              )
    	        values(
    	                #{name}
    	              , #{team}
    	              )
    </insert>    
</mapper>
```

#### service
Mapper 인터페이스를 호출하여 비즈니스 로직을 처리합니다.
```java
package com.pet.aki.cmm.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.pet.aki.cmm.mapper.MemberMapper;
import com.pet.aki.cmm.model.MemberVO;

@Service
@Transactional
public class MemberService {

	@Autowired
	MemberMapper memberMapper;

	public MemberVO selectMemberById(Long id) {
		return memberMapper.selectMemberById(id);
	}

	public List<MemberVO> selectMemberList() {
		return memberMapper.selectMemberList();
	}

	public void insertMember(MemberVO memberVO) {
		memberMapper.insertMember(memberVO);
	}

}
```

#### 컨트롤러
기존에 사용하던 컨트롤러 그대로 사용합니다. helloWorld() 메서드에서 서비스의 selectMemberList()
메서드를 호출하여 DB 정보를 확인합니다.
```java
package com.pet.aki.cmm.web;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.pet.aki.cmm.model.MemberVO;
import com.pet.aki.cmm.service.MemberService;

@Controller
@EnableAutoConfiguration
public class HelloWorldController {

	@Autowired
	private MemberService service;

	@RequestMapping("/")
	public String index() {
		System.out.println("@RequestMapping(\"/\")");
		return "index";
	}

	@RequestMapping("/hello")
	@ResponseBody
	public String helloWorld() throws Exception {
		System.out.println("@RequestMapping(\"/hello\")");

		List<MemberVO> list = service.selectMemberList();

		for (int i = 0; i < list.size(); i++) {
			System.out.println("name : " + list.get(i).getName());
			System.out.println("team : " + list.get(i).getTeam());
		}

		return "/com/pet/aki/cmm/hello";
	}

	@RequestMapping("/insert")
	@ResponseBody
	public String insert() throws Exception {
		System.out.println("@RequestMapping(\"/insert\")");

		MemberVO vo = new MemberVO();

		vo.setName("이동국");
		vo.setTeam("전북 현대 모터스");

		service.insertMember(vo);

		return "/com/pet/aki/cmm/insert";
	}
}
```

#### spring Application
spring boot 시작 클래스 MyBatis의 sqlSessionFactory 얻는 Bean을 설정합니다.
```java
package com.pet.aki;

import javax.sql.DataSource;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

@SpringBootApplication
@MapperScan(value = { "com.pet.aki.**.mapper" })
public class AkiApplication {

	public static void main(String[] args) {
		SpringApplication.run(AkiApplication.class, args);
	}

	@Bean
	public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception {
		SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
		sessionFactory.setDataSource(dataSource);

		Resource[] res = new PathMatchingResourcePatternResolver().getResources("classpath:com/pet/aki/**/*Mapper.xml");
		sessionFactory.setMapperLocations(res);

		return sessionFactory.getObject();
	}

}
```
Mapper 인터페이스 스캔 com.pet.aki 이하 패키지들 중 mapper 패키지를 스캔합니다.
```
@MapperScan(value = { "com.pet.aki.**.mapper" })
```
Mapper XML 스캔 resources 폴터 이하 com.pet.aki 이하 패키지에서 Mapper.xml로 끝나는 Mapper XML을 스캔합니다.
```
Resource[] res = new PathMatchingResourcePatternResolver().getResources("classpath:com/pet/aki/**/*Mapper.xml");
```

#### 실행
bootRun을 실행하고 http://localhost:8080/hello 접속
```
RequestMapping("/hello")
2019-03-14 17:10:17.406  INFO 16888 --- [nio-8080-exec-1] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2019-03-14 17:10:17.415  WARN 16888 --- [nio-8080-exec-1] com.zaxxer.hikari.util.DriverDataSource  : Registered driver with driverClassName=com.mysql.jdbc.Driver was not found, trying direct instantiation.
2019-03-14 17:10:18.036  INFO 16888 --- [nio-8080-exec-1] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2019-03-14 17:10:18.269  INFO 16888 --- [nio-8080-exec-1] c.pet.aki.cmm.web.HelloWorldController   : data - [com.pet.aki.cmm.model.MemberVO@3d5ed5fe, com.pet.aki.cmm.model.MemberVO@72929480, com.pet.aki.cmm.model.MemberVO@4c615b67, com.pet.aki.cmm.model.MemberVO@54c78282]
name : 박지성
team : 맨체스터유나이티드
name : 기성용
team : 스완지시티
name : 손홍민
team : 토트넘
name : 111
team : 222
```


### 참조사이트
https://gangnam-americano.tistory.com/63
