---
layout:   post
title:    STS IDE spring boot, integration, sftp 다운로드
author:   harry
tags:     [post, dev, spring, integration, sftp, spring boot, STS]
comments: false
---
<!-- Start Writing Below in Markdown -->

# STS spring boot 기반 integration sftp 다운로드

## 프로젝트 생성

### 1) 생성
File -> New -> Spring Starter Project 선택
![](/images/spring_integration/integration_01.png "boot 프로젝트 생성")<br/>
<br/>

### 2) 빌드 설정
Type: Gradle 선택 (본인이 선호하는 툴 선택)<br/>
Packageing: Jar 선택 (저는 jar파일로 빌드해서 실행했습니다.)<br/>
Java Version: 8이상 선택<br/>
![](/images/spring_integration/integration_02.png "boot 프로젝트 생성")

### 3) 라이브러리
Core - Lombok, Integration - Spring Integration(필수) 선택
![](/images/spring_integration/integration_03.png "boot 프로젝트 생성")

### 4) 확인
![](/images/spring_integration/integration_04.png "boot 프로젝트 생성")

```url
https://start.spring.io/starter.zip?name=demo&groupId=com.example&artifactId=demo&version=0.0.1-SNAPSHOT&description=Demo+project+for+Spring+Boot&packageName=com.example.demo&type=gradle-project&packaging=jar&javaVersion=1.8&language=java&bootVersion=2.1.1.RELEASE&dependencies=lombok&dependencies=integration
```

### 5) 결과물
![](/images/spring_integration/integration_05.png "boot 프로젝트 생성")

## 소스 편집

### 1) properties 파일 생성
src/main/resources에 sftp.properties 파일 생성
```properties
sftp.host=XXX.XXX.XXX.XXX
sftp.port=22
sftp.user=userid
sftp.password=userpassword

sftp.remote.directory.download.filter=*.csv
sftp.remote.directory.as=/home/user/ftp_test_data/as/
sftp.remote.directory.car=/home/user/ftp_test_data/car/
sftp.remote.directory.cust=/home/user/ftp_test_data/cust/
sftp.remote.directory.user=/home/user/ftp_test_data/user/
sftp.local.directory.as=/home/harry/inboundFiles/as/
sftp.local.directory.car=/home/harry/inboundFiles/car/
sftp.local.directory.cust=/home/harry/inboundFiles/cust/
sftp.local.directory.user=/home/harry/inboundFiles/user/
```

### 2) sftp 의존성 추가
아래 내용을 build.gradle 파일 마지막 dependencies {} 안에 추가
```
compile "org.springframework.integration:spring-integration-sftp:5.1.1.RELEASE"
compile group: 'org.apache.sshd', name: 'sshd-sftp', version: '2.1.0'
```
프로젝트 우클릭 Gradle -> Refresh Gradle Project
![](/images/spring_integration/integration_06.png "boot 프로젝트 생성")

### 3) 실제 sftp 전송 소스
DemoApplication.java 편집
```java
import java.io.File;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.io.Resource;
import org.springframework.integration.dsl.IntegrationFlow;
import org.springframework.integration.dsl.IntegrationFlows;
import org.springframework.integration.dsl.Pollers;
import org.springframework.integration.file.remote.session.CachingSessionFactory;
import org.springframework.integration.file.remote.session.SessionFactory;
import org.springframework.integration.sftp.dsl.Sftp;
import org.springframework.integration.sftp.session.DefaultSftpSessionFactory;

import com.jcraft.jsch.ChannelSftp.LsEntry;


@SpringBootApplication
@PropertySource("classpath:/sftp.properties")
public class DemoApplication {

    @Value("${sftp.host}")
    private String sftpHost;

    @Value("${sftp.port}")
    private int sftpPort;

    @Value("${sftp.user}")
    private String sftpUser;

    @Value("${sftp.privateKey:#{null}}")
    private Resource sftpPrivateKey;

    @Value("${sftp.privateKeyPassphrase:}")
    private String sftpPrivateKeyPassphrase;

    @Value("${sftp.password}")
    private String sftpPasword;

    @Value("${sftp.remote.directory.download.filter}")
    private String sftpRemoteDirectoryDownloadFilter;

    @Value("${sftp.remote.directory.car}")
    private String sftpRemoteDirectoryCar;

    @Value("${sftp.remote.directory.user}")
    private String sftpRemoteDirectoryUser;

    @Value("${sftp.local.directory.car}")
    private String sftpLocalDirectoryCar;

    @Value("${sftp.local.directory.user}")
    private String sftpLocalDirectoryUser;


    @Bean
    public SessionFactory<LsEntry> sftpSessionFactory() {

        DefaultSftpSessionFactory factory = new DefaultSftpSessionFactory(true);

        factory.setHost(sftpHost);
        factory.setPort(sftpPort);
        factory.setUser(sftpUser);
        factory.setPassword(sftpPasword);
        factory.setAllowUnknownKeys(true);
        //factory.setTestSession(true);

        return new CachingSessionFactory<LsEntry>(factory);
    }


    @Bean
    public IntegrationFlow sftpInboundFlow() {

        return IntegrationFlows
            .from(Sftp.inboundAdapter( this.sftpSessionFactory() )
                    .preserveTimestamp(true)
                    .remoteDirectory(sftpRemoteDirectoryUser)
                    .regexFilter(".*\\.csv$")
                    //.localFilenameExpression("#this.toUpperCase() + '.a'")
                    .localDirectory(new File(sftpLocalDirectoryUser)),
                 e -> e.id("sftpInboundAdapter")
                    .autoStartup(true)
                    .poller(Pollers.fixedDelay(10000)))
            .handle(m -> System.out.println(m.getPayload() + " | handler1" ))
            .get();
    }


    @Bean
    public IntegrationFlow sftpInboundFlow2() {

        return IntegrationFlows
            .from(Sftp.inboundAdapter(this.sftpSessionFactory())
                    .preserveTimestamp(true)
                    .remoteDirectory(sftpRemoteDirectoryCar)
                    .regexFilter(".*\\.csv$")
                    //.localFilenameExpression("#this.toUpperCase() + '.a'")
                    .localDirectory(new File(sftpLocalDirectoryCar)),
                 e -> e.id("sftpInboundAdapter2")
                    .autoStartup(true)
                    .poller(Pollers.fixedDelay(10000)))
            .handle(m -> System.out.println(m.getPayload() + " | handler2" ))
            .get();
    }


    public static void main(String[] args) {

        SpringApplication.run(DemoApplication.class, args);
    }

}
```
