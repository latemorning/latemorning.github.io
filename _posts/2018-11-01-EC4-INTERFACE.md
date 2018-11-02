---
layout:   post
title:    EC4 INTERFACE
author:   harry
tags:     post ec4
subtitle: .
category: .
comments: false
---
<!-- Start Writing Below in Markdown -->


#### 인터페이스 대상
* 고객정보
* 차량정보
* A/S정보
* 포인트정보
* 해피콜
* 사업소/메이커
* 정비소위치 URL
* 영업소 마스타
* 차종코드 마스타


#### 인터페이스 방식
* DB link
* DB Connection Pool(WAS)
* JDBC
* 화면 링크(웹 화면 링크 이용)
* API or Open API
* 연계 솔루션(EAI)
* Web Service/ESB
* **Socket / FTP 파일 연동**
  * 포인트정보 - Socket 방식
  * 나머지 - FTP 파일 연동

#### 개발 기술
* spring 배치(egov) EC4Batch
* FTP, Socket 통신
