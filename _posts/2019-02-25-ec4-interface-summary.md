---
layout:   post
title:    EC4 인터페이스 작업 요약
author:   harry
tags:     [egov, batch, 인터페이스]
comments: false

---
<!-- Start Writing Below in Markdown -->

## 소스 저장소
* http://서버주소:7443/svn/wizvil_ec4_batch

## 작업 요약
* 히스토리 테이블 및 인터페이스 테이블 생성
* job 설정파일 생성 resources/egovframework/batch/job/ job xml 생성
  * resources/egovframework/batch/properties/location.properties 에 source.directory.XXX, source.file.XXX 설정
* 샘플용 text파일 생성("\|"로 각 필드 구분)
* 매핑용 VO class 생성
* Processor class 생성
* HistProcessor class 생성
* SQL 쿼리 생성 resources/egovframework/sqlmap/ec4/bat/
* egovframework.example.bat.scheduler.EgovSchedulerJobRunner.java 에 job 설정파일 등록
* resources/egovframework/batch/context-batch-scheduler.xml 에 cron trigger 등록
* resources/egovframework/batch/context-scheduler-job.xml 에 job detail 등록
* resources/egovframework/sqlmap/sql-map-config.xml 에 SQL 쿼리 파일 등록

## 실행
* EgovSchedulerJobRunner.java 파일 실행시킨다.
