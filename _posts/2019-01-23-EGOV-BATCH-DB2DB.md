---
layout:   post
title:    EGOV BATCH DB to DB
author:   harry
tags:     [egov, batch]
comments: false
---
<!-- Start Writing Below in Markdown -->

# 전자정부 프레임 배치 사용 DB 마이그레이션

전자정부 프레임에서 제공하는 DB to DB 배치를 이용하여 간단한 마이그레이션 작업이
가능할 것 같아서 시도해봄
모든 소스는 아래 [gitHub](https://github.com/latemorning/egov.commandline.batch)에 있음

## 프로젝트 생성

 - eGovFrame - Start - New Batch Template Project

![new_project_01](/images/egov_batch/new_project_01.png)

DB to DB 작업 샘플이 필요하므로 DB 선택
![new_project_02](/images/egov_batch/new_project_02.png)

바로 결과를 확인해야 하니 CommandLine 선택
![new_project_03](/images/egov_batch/new_project_03.png)

프로젝트 정보를 적당히 입력해줍시다.
![new_project_04](/images/egov_batch/new_project_04.png)

Maven 기반으로 아래와 같이 프로젝트가 생성됩니다.
![new_project_05](/images/egov_batch/new_project_05.png)

## job 파일 설정

DB to DB 작업을 위해서 샘플 파일 중 ibatisToIbatisJob.xml 파일을 복사해서
migReplcJob.xml 라고 새로운 파일을 생성했습니다. 이름은 각자 취향대로 설정하세요
![job_setting_01](/images/egov_batch/job_setting_01.png)

#### job 설정

아래 예제처럼 job - step - tasklet - chunk 순서로 기술하고
step은 여러 개 작성 가능 자세한 내용은 검색….
대충 보면 migReplcItemReader로 DB에서 읽고 migReplcProcessor로 데이터 가공
migReplcItemWriter로 DB에 쓰는 작업을 할 거라고 예측 가능
```xml
<job id="migReplcJob" parent="eGovBaseJob" xmlns="http://www.springframework.org/schema/batch">
  <step id="migReplcStep" parent="eGovBaseStep">
    <tasklet>
      <chunk reader="migReplcItemReader" processor="migReplcProcessor"
        writer="migReplcItemWriter" commit-interval="100" />
    </tasklet>
  </step>
</job>
```

#### reader 설정
원본 데이터를 읽어올 select 문장의 queryId 지정, 나머지는 기본 설정
```xml
<bean id="migReplcItemReader" class="org.springframework.batch.item.database.IbatisPagingItemReader">
  <property name="queryId" value="selectShopInfoList" />
  <property name="sqlMapClient" ref="sqlMapClient" />
  <property name="dataSource" ref="dataSource" />
</bean>
```

#### writer 설정
데이터를 저장할 insert 문장의 queryId 지정, 나머지는 기본 설정
```xml
<bean id="migReplcItemWriter" class="org.springframework.batch.item.database.IbatisBatchItemWriter">
  <property name="statementId" value="insertReplc" />
  <property name="sqlMapClient" ref="sqlMapClient" />
  <property name="dataSource" ref="dataSource" />
</bean>
```

#### processor 설정
데이터 가공이 필요할 때 사용할 bean
```xml
<bean id="migReplcProcessor" class="egovframework.example.bat.domain.replc.ReplcProcessor" />
```

## Bean 생성

Bean을 생성할 Package 생성
![create_bean_01](/images/egov_batch/create_bean_01.png)

VO 객체와 processor Bean 생성
![create_bean_02](/images/egov_batch/create_bean_02.png)


#### Replc VO
insert 할 대상 테이블
테이블에 맞게 필드를 생성하고 생성자, toString, getter/setter 메서드 생성
```java
package egovframework.example.bat.domain.replc;

import javax.persistence.Entity;
import javax.persistence.Table;

@Entity
@Table(name = "OB_REPLC")
public class Replc {

    private String replcCode = "";
    private String replcTy = "";
    private String replcNm = "";
    private String replcGdcc = "";
    private String replcExcpGdcc = "";
    private String smsDsptchNo = "";
    private String replcEmail = "";
    private String useAt = "";
    private String scdCallUseAt = "";
    private String hdqrtrsCode = "";
    private String remark = "";
    private String frstRegistPnttm = "";
    private String frstRegisterId = "";
    private String lastUpdtPnttm = "";
    private String lastUpdusrId = "";


    public Replc() {

    }
    이하 줄임...
```
#### ShopInfo VO
select 할 테이블
위 Replc VO처럼 테이블에 맞게 필드를 생성하고
생성자, toString, getter/setter 메서드 생성

#### Replc processor
ItemProcessor 구현하고 process 메서드를 Override함
process 메서드에서 데이터를 가공하고 return 함
```java
package egovframework.example.bat.domain.replc;

import org.springframework.batch.item.ItemProcessor;

public class ReplcProcessor implements ItemProcessor<ShopInfo, Replc> {

    public ReplcProcessor() {
    }


    @Override
    public Replc process(ShopInfo item) throws Exception {

        Replc replc = new Replc();

        return replc;
    }

}
```

## 쿼리 작업

#### sql-map-config.xml 작성
![query_01](/images/egov_batch/query_01.png)

쿼리를 작성할 파일 정보 추가
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE sqlMapConfig PUBLIC "-//iBATIS.com//DTD SQL Map Config 2.0//EN"
    "http://www.ibatis.com/dtd/sql-map-config-2.dtd">

<sqlMapConfig>
    <!-- <sqlMap resource="egovframework/sqlmap/example/bat/Egov_Example_SQL.xml"/> -->
    <!-- <sqlMap resource="egovframework/sqlmap/example/bat/Egov_Example_SQL_tibero.xml"/> -->
    <!-- <sqlMap resource="egovframework/sqlmap/example/bat/Egov_Example_SQL_altibase.xml"/> -->
    <!-- <sqlMap resource="egovframework/sqlmap/example/bat/Egov_Example_SQL_mysql.xml"/> -->
    <!-- <sqlMap resource="egovframework/sqlmap/example/bat/Egov_Example_SQL_oracle.xml"/> -->
    <!-- <sqlMap resource="egovframework/sqlmap/example/bat/Egov_Example_SQL_cubrid.xml"/> -->
    <sqlMap resource="egovframework/sqlmap/example/bat/Egov_Replc_SQL.xml"/>
</sqlMapConfig>
```

#### Egov_Replc_SQL.xml 작성
쿼리 작성하기 전 전체 구조
shopInfo는 source 테이블 VO, replc는 target 테이블 VO
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE sqlMap PUBLIC "-//ibatis.apache.org//DTD SQL Map 2.0//EN" "http://ibatis.apache.org/dtd/sql-map-2.dtd">

<sqlMap namespace="Replc">

    <typeAlias alias="replc" type="egovframework.example.bat.domain.replc.Replc" />
    <typeAlias alias="shopInfo" type="egovframework.example.bat.domain.replc.ShopInfo" />

    <select id="selectShopInfoList" resultClass="shopInfo">
    <![CDATA[

    ]]>		
    </select>

    <insert id="insertReplc" parameterClass="replc">
    <![CDATA[

    ]]>		
    </select>
</sqlMap>
```

#### selectShopInfoList 작성
SHOP_INFO 테이블 select 할때 pageing 쿼리를 사용해야함
_page, _pagesize, _skiprows 는 org.springframework.batch.item.database.IbatisPagingItemReader 에 정의되어 있음
```xml
<select id="selectShopInfoList" resultClass="shopInfo">
  <![CDATA[
      SELECT
              *
        FROM
            (
              SELECT
                      rownum AS rn
                    , TB.*
                FROM
                    (
                      SELECT
                              shop_code                           AS shopCode
                            , shop_type                           AS shopType
                            , shop_name                           AS shopName
                            , usr_id                              AS usrId
                            , shop_cal_sct                        AS shopCalSct
                            , shop_sms_sct                        AS shopSmsSct
                            , shop_sms_mk                         AS shopSmsMk
                            , shop_sms_abs_sct                    AS shopSmsAbsSct
                            , shop_sms_abs_mk                     AS shopSmsAbsMk
                            , shop_sms_sedno                      AS shopSmsSedno
                            , shop_exc                            AS shopExc
                            , shop_email                          AS shopEmail
                            , shop_del_mk                         AS shopDelMk
                            , shop_remark                         AS shopRemark
                            , reg_id                              AS regId
                            , TO_CHAR(reg_dt, 'YYYYMMDDHH24MISS') AS regDt
                            , chg_id                              AS chgId
                            , TO_CHAR(chg_dt, 'YYYYMMDDHH24MISS') AS chgDt
                            , shop_ot_seq                         AS shopOtSeq
                            , regn_fg                             AS regnFg
                            , shop_sms_res_sct                    AS shopSmsResSct
                            , shop_sms_res_mk                     AS shopSmsResMk
                            , shop_sms_resb_sct                   AS shopSmsResbSct
                            , shop_sms_resb_mk                    AS shopSmsResbMk
                            , cal2_usr_mk                         AS cal2UsrMk
                        FROM
                              shop_info
                       WHERE
                              1 = 1
                       ORDER BY
                              shop_code
                    ) TB
               WHERE
                      rownum <= (#_page# + 1) * #_pagesize#
            )
       WHERE
              rn >= #_skiprows# + 1
  ]]>
</select>
```

#### shopInfo 를 replc 로 변환
process 메서드에서 SHOP_INFO 에서 select 한 필드를 OB_REPLC 테이블에 세팅해서 return 한다.
return 된 replc VO 는 insertReplc 쿼리에서 사용된다.
```java
package egovframework.example.bat.domain.replc;

import org.springframework.batch.item.ItemProcessor;

public class ReplcProcessor implements ItemProcessor<ShopInfo, Replc> {

    public ReplcProcessor() {
    }


    @Override
    public Replc process(ShopInfo item) throws Exception {

        Replc replc = new Replc();

        replc.setReplcCode(item.getShopCode());
        replc.setReplcTy(item.getShopType());
        replc.setReplcNm(item.getShopName());
        replc.setReplcGdcc(item.getShopCalSct());
        replc.setSmsDsptchNo(item.getShopSmsSedno());
        replc.setReplcExcpGdcc(item.getShopExc());
        replc.setReplcEmail(item.getShopEmail());
        replc.setUseAt(item.getShopDelMk());
        replc.setRemark(item.getShopRemark());
        replc.setFrstRegisterId(item.getRegId());
        replc.setFrstRegistPnttm(item.getRegDt());
        replc.setLastUpdusrId(item.getChgId());
        replc.setLastUpdtPnttm(item.getChgDt());
        replc.setHdqrtrsCode(item.getRegnFg());
        replc.setScdCallUseAt(item.getCal2UsrMk());

        return replc;
    }

}
```

#### insertReplc 작성
```xml
<insert id="insertReplc" parameterClass="replc">
<![CDATA[
INSERT INTO
       ob_replc (
                  replc_code
                , replc_ty
                , replc_nm
                , replc_gdcc
                , replc_excp_gdcc
                , sms_dsptch_no
                , replc_email
                , use_at
                , scd_call_use_at
                , hdqrtrs_code
                , remark
                , frst_regist_pnttm
                , frst_register_id
                , last_updt_pnttm
                , last_updusr_id
                )
         VALUES (
                  #replcCode#
                , #replcTy#
                , #replcNm#
                , #replcGdcc#
                , #replcExcpGdcc#
                , #smsDsptchNo#
                , #replcEmail#
                , #useAt#
                , #scdCallUseAt#
                , #hdqrtrsCode#
                , #remark#
                , TO_DATE(#frstRegistPnttm#, 'YYYYMMDDHH24MISS')
                , #frstRegisterId#
                , TO_DATE(#lastUpdtPnttm#, 'YYYYMMDDHH24MISS')
                , #lastUpdusrId#
                )
]]>
</insert>
```

## dataSource 설정
읽어올 DB와 저장할 DB가 다르기 때문에 각각 dataSource를 설정해야 함
본 예제에서는 Oracle 데이터베이스를 사용함
#### context-batch-datasource.xml 설정
공통 propertise 파일 import
```properties
<bean id="egov.propertyConfigurer" class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
      <property name="locations">
          <list>
              <value>classpath:/egovframework/batch/properties/globals.properties</value>
          </list>
      </property>
  </bean>
```

dataSource-oracle 데이터를 저장할 target DB 정보
dataSource-oracle-0 데이터를 읽어올 source DB 정보
나머지 설정은 그대로 유지
```properties
<!-- DataSource -->
<alias name="dataSource-${Globals.DbType}"   alias="egov.dataSource"/>
<alias name="dataSource-${Globals.DbType}"   alias="dataSource"/>   <!-- target -->
<alias name="dataSource-${Globals.DbType}-0" alias="dataSource0"/>  <!-- source -->

<!-- Oracle -->
<!-- target -->
<bean id="dataSource-oracle" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
  <property name="driverClassName" value="${Globals.DriverClassName}"/>
  <property name="url" value="${Globals.Url}"/>
  <property name="username" value="${Globals.UserName}"/>
  <property name="password" value="${Globals.Password}"/>
</bean>

<!-- source -->
<bean id="dataSource-oracle-0" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
  <property name="driverClassName" value="${Globals.DriverClassName}"/>
  <property name="url" value="${Globals.Url0}" />
  <property name="username" value="${Globals.UserName0}"/>
  <property name="password" value="${Globals.Password0}"/>
</bean>
```

#### globals.properties 설정
데이터를 읽어올 DB와 저장할 DB 정보를 설정
```properties
# DB서버 타입(hsql, mysql, oracle, altibase, tibero, cubrid) - datasource 및 sqlMap 파일 지정에 사용됨
Globals.DbType = oracle

#oracle
Globals.DriverClassName=oracle.jdbc.driver.OracleDriver
Globals.Url=jdbc:oracle:thin:@ec4.dev:1521:xe
Globals.UserName=로그인id
Globals.Password=로그인pass

Globals.Url0=jdbc:oracle:thin:@ec4.dev:1523:xe
Globals.UserName0=로그인id
Globals.Password0=로그인pass
```

#### 오라클 드라이버 ojdbc6.jar
pom.xml에 설정함
저는 maven 로컬 저장소를 운영하기 때문에 아래처럼 설정하면 되지만
이글을 보고 하시는 분은 다른 방법으로 해결하시기 바랍니다.
classpath에 ojdbc6.jar 파일이 걸려있으면 됩니다.
```xml
<dependency>
    <groupId>com.oracle</groupId>
    <artifactId>ojdbc6</artifactId>
    <version>11.2.0.4.0</version>
</dependency>
```

#### job 수정
migReplcJob의 migReplcItemReader는 위에서 설정한 dataSource0 을 사용하게 수정
읽어오는 DB와 저장하는 DB 구분
```xml
<bean id="migReplcItemReader" class="org.springframework.batch.item.database.IbatisPagingItemReader">
  <property name="queryId" value="selectShopInfoList" />
  <property name="sqlMapClient" ref="sqlMapClient" />
  <property name="dataSource" ref="dataSource0" />
</bean>
```

## 실행하기
EgovCommandLineJobRunner.java 우클릭 - Run As - Run Configurations
파라메터로 공통 설정파일 위치와 실행할 job 이름 입력
![execute_01](/images/egov_batch/execute_01.png)
![execute_02](/images/egov_batch/execute_02.png)
