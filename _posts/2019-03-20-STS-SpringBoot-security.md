---
layout:   post
title:    STS Spring Boot Spring Security 사용하기
author:   harry
tags:     [Spring Boot, Spring Security]
comments: true
published : true
---

## STS Spring Boot Spring Security 사용하기

### 의존성 build.gradle
```
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    //providedRuntime 'org.springframework.boot:spring-boot-starter-tomcat'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    compile('javax.servlet:jstl')
    compile("org.apache.tomcat.embed:tomcat-embed-jasper")
    implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:2.0.0'
    runtimeOnly 'mysql:mysql-connector-java'
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    testImplementation 'org.springframework.security:spring-security-test'
}
```

### 컨트롤러
```java
package com.pet.aki.cmm.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HelloWorldController {

    @RequestMapping("/")
    public String index() {

        return "index";
    }


    @RequestMapping("/hello")
    public String helloWorld() {

        return "/com/pet/aki/cmm/hello";
    }


    @RequestMapping("/admin")
    public String admin() {

        return "/com/pet/aki/cmm/admin";
    }


    @RequestMapping("/guest")
    public String guest() {

        return "/com/pet/aki/cmm/guest";
    }


    @RequestMapping("/manager")
    public String manager() {

        return "/com/pet/aki/cmm/manager";
    }
}
```

### bootRun 실행
서버 실행하고 localhost:8080/hello 에 접속해보자 내가 만든적도 없는 로그인 화면이 보인다. 스프링 시큐리티 기본 설정에 모든 자원은 인증을 통과해야 되기때문에 기본 로그인 화면이 출력된다.
![img_02](/images/2019-03-20-STS-SpringBoot-security/img_02.png)

### 클래스 다이어그램
![img_04](/images/2019-03-20-STS-SpringBoot-security/img_04.png)

### 사용자 정의 Member 생성
spring security에는 UserDetails라는 인터페이스가 인증과 관련된 사용자를 나타내고 이를 구현한 User 클래스가 있다. 우리는 Member라는 객체를 만들고 UserDetails 를 구현하여 인증에 Member 객체를 사용해 보기로 하겠다. UserDetails 를 구현하면 기본적으로 필요한 필드와 메서드들이 생성된다. 자동으로 생성된 메서드들은 적당히 소스를 수정해주고(어렵지않음) 생성자는 직접 추가했는데 계정 잠금과 만료에 관한 설정으로 지금은 사용할 일이 없기때문에 3개의 변수를 true로 강제 셋팅했다.  
```java
package com.pet.aki.sec.domain;

import java.util.Collection;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

public class Member implements UserDetails {

    private static final long serialVersionUID = 1L;

    private String username;
    private String password;
    private String memberName;
    private final boolean accountNonExpired;
    private final boolean accountNonLocked;
    private final boolean credentialsNonExpired;
    private boolean enabled;
    private Collection<? extends GrantedAuthority> authorities;


    public Member() {

        this.accountNonExpired = true;
        this.accountNonLocked = true;
        this.credentialsNonExpired = true;
    }


    @Override
    public String getUsername() {

        return this.username;
    }


    public void setUsername(String username) {

        this.username = username;
    }


    @Override
    public String getPassword() {

        return this.password;
    }


    public void setPassword(String password) {

        this.password = password;
    }


    public String getMemberName() {

        return this.memberName;
    }


    public void setMemberName(String memberName) {

        this.memberName = memberName;
    }


    @Override
    public boolean isAccountNonExpired() {

        return this.accountNonExpired;
    }


    @Override
    public boolean isAccountNonLocked() {

        return this.accountNonLocked;
    }


    @Override
    public boolean isCredentialsNonExpired() {

        return this.credentialsNonExpired;
    }


    @Override
    public boolean isEnabled() {

        return this.enabled;
    }


    public void setEnabled(boolean enabled) {

        this.enabled = enabled;
    }


    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {

        return authorities;
    }


    public void setAuthorities(Collection<? extends GrantedAuthority> authorities) {

        this.authorities = authorities;
    }
}
```

### 기본테이블 구조
![img_03](/images/2019-03-20-STS-SpringBoot-security/img_03.png)


### 테스트 데이타
```sql
INSERT INTO members (username, password, member_name, is_enabled) VALUES ('username1', 'password1', 'member_name 1', 1);
INSERT INTO members (username, password, member_name, is_enabled) VALUES ('username2', 'password2', 'member_name 2', 1);
INSERT INTO members (username, password, member_name, is_enabled) VALUES ('username3', 'password3', 'member_name 3', 1);
INSERT INTO members (username, password, member_name, is_enabled) VALUES ('username4', 'password4', 'member_name 4', 1);
INSERT INTO members (username, password, member_name, is_enabled) VALUES ('username5', 'password5', 'member_name 5', 1);

INSERT INTO authoritys (authority_code, authority_name) VALUES ('ROLE_ADMIN', '관리자');
INSERT INTO authoritys (authority_code, authority_name) VALUES ('ROLE_USER', '사용자');
INSERT INTO authoritys (authority_code, authority_name) VALUES ('ROLE_ANONYMOUS', '익명 사용자');

INSERT INTO member_authority (username, authority_code) VALUES ('username1', 'ROLE_ADMIN');
INSERT INTO member_authority (username, authority_code) VALUES ('username2', 'ROLE_USER');
INSERT INTO member_authority (username, authority_code) VALUES ('username3', 'ROLE_USER');
INSERT INTO member_authority (username, authority_code) VALUES ('username4', 'ROLE_USER');
INSERT INTO member_authority (username, authority_code) VALUES ('username5', 'ROLE_ANONYMOUS');

```

### 사용자 정의 인증 서비스
spring security의 UserDetailsService를 구현하여 MemberService를 생성한다. UserDetailsService에는 loadUserByUsername(String):UserDetails라는 메서드가 하나 존재 하는데 이 메서드를 구현하여 UserDetails 객체를 리턴하게 만들어주면 된다. 권한 목록을 구하는 selectAuthorities(String):List<GrantedAuthority> 메서드는 직접 작성했다.
```java
package com.pet.aki.sec.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.pet.aki.sec.domain.Member;
import com.pet.aki.sec.mapper.MemberMapper;

@Service
public class MemberService implements UserDetailsService {

    @Autowired
    MemberMapper memberMapper;


    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        Member member = memberMapper.selectMember(username);
        member.setAuthorities(this.selectAuthorities(username));

        return member;
    }


    public List<GrantedAuthority> selectAuthorities(String username) {

        List<String> stringAuthorities = memberMapper.selectAuthorities(username);

        List<GrantedAuthority> authorities = new ArrayList<GrantedAuthority>();

        for (String authority : stringAuthorities) {
            authorities.add(new SimpleGrantedAuthority(authority));
        }
        return authorities;
    }
}
```

### Mapper 작성
MemberService 에서 사용하는 Mapper 작성 MyBatis를 사용하여 MySQL 에 연결하는 mapper 작성 MyBatis 연동은 여기서 별도로 설명하지 않음 selectMember(String username):UserDetails 메서드와 selectAuthority(String username):List<String> 메서드를 작성합니다.
```java
package com.pet.aki.sec.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.pet.aki.sec.domain.Member;

@Mapper
public interface MemberMapper {

    public Member selectMember(String username);


    public List<String> selectAuthorities(String username);
}
```


### Mapper 쿼리 작성
username으로 사용자 정보를 가져오는 쿼리와 사용자 권한 목록을 가져오는 쿼리를 작성

```sql
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="com.pet.aki.sec.mapper.MemberMapper">

    <select id="selectMember" parameterType="java.lang.String" resultType="com.pet.aki.sec.domain.Member">
        SELECT
                username
              , password
              , true AS enabled
              , member_name AS "memberName"
          FROM
                member
         WHERE
                username = #{username}
    </select>

    <select id="selectAuthorities" parameterType="java.lang.String" resultType="java.lang.String">
    	SELECT
    	        a.authority_code
    	  FROM
    	        member m
    	      , authority a
    	      , member_authority ma
    	 WHERE
    	        m.username = ma.username
    	   AND  ma.authority_code = a.authority_code
    	   AND  m.username = #{username}
    </select>
</mapper>
```

### SecurityConfig 작성
Spring Security를 사용하기 위한 기본 설정파일로 WebSecurityConfigurerAdapter 를 상속받아 사용자 환경에 맞게 구현한다. configure(HttpSecurity http) 에서 http url 접근에 대한 설정을 한다. configure(AuthenticationManagerBuilder auth) 에서는 인증에 사용할 인증매니저를 셋팅한다. 위에서 만든 인증서비스를 셋팅한다. noOpPasswordEncoder는 평문을 그대로 사용하는 인코더로 PasswordEncoder를 사용하지 않으면 로그인이 제대로 되지 않는다.
```java
package com.pet.aki.sec.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.pet.aki.sec.service.MemberService;

@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    MemberService memberService;


    @Override
    public void configure(HttpSecurity http) throws Exception {

        http.authorizeRequests().antMatchers("/guest/**").permitAll();
        http.authorizeRequests().antMatchers("/manager/**").hasRole("USER");
        http.authorizeRequests().antMatchers("/admin/**").hasRole("ADMIN");
        http.formLogin();//.loginPage("/login");
        http.exceptionHandling().accessDeniedPage("/accessDenied");
        http.logout().logoutUrl("/logout").invalidateHttpSession(true);
    }


    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {

        auth.userDetailsService(memberService).passwordEncoder(noOpPasswordEncoder());

    }


    @Bean
    public PasswordEncoder noOpPasswordEncoder() {

        return NoOpPasswordEncoder.getInstance();
    }
}
```

### 테스트
bootRun을 실행하고 브라우저 접속 localhost:8080으로 접속하면 / 로 접속돼서 index 페이지가 나타난다. 위에서 /manager/** 패턴은 USER 권한이 필요하게 설정했었다. USER 권한을 가지고 있는 username3 으로 로그인해 본다. 접속이 돼야 한다. 접속됐다면 /admin으로 접속해본다. 권한이 없어서 그런지 404 오류가 발생 403 권한 없음 페이지가 나오지 않고 404 오류가 발생하는 건 보안상 이유로 403 오류가 발생하면 해당 페이지가 존재한다는 걸 예측할 수 있기 때문이다. 설정으로 변경할 수 있다. USER 권한과 ADMIN 권한 둘 다 가지고 있는 username1 계정으로 접속해보면 양쪽 페이지에 잘 접속되는걸 확인할 수 있다.
