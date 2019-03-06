---
layout:   post
title:    EGOV BATCH FILE to DB
author:   harry
tags:     [egov, batch]
comments: true
published : false
---
<!-- Start Writing Below in Markdown -->

# 전자정부프레임 배치 FILE to DB

전자정부프레임 배치 FILE to DB 작업 예제

## 프로젝트 생성

메뉴에서 eGovFrame > Start > New Batch Template Project 선택
![new_project_01](/images/egov_batch/new_project_01.png)

FILE to DB 작업 샘플이 필요하므로 File(SAM) 선택
![filetodb_01](/images/egov_batch/filetodb_01.png)

Scheduler를 사용 선택
![filetodb_01](/images/egov_batch/filetodb_02.png)

프로젝트 정보는 아래 이미지를 참고하여 적당히 입력
![new_project_04](/images/egov_batch/new_project_04.png)

Maven 기반으로 아래와 같이 프로젝트가 생성됨
![new_project_05](/images/egov_batch/new_project_05.png)

## job 파일

FILE to DB 작업을 위해서 샘플 파일 중 fixedLengthToIbatisJob.xml 파일을 복사하여 새로운 파일 생성 이름은 각자 네이밍 규칙에 맞춰 생성
아래 설정은 첫번째 step 파일에서 읽은 데이터를 중간 테이블에 insert하고, 다음 step에서 이전 step에서 insert한 데이타를 읽어와서 최종 테이블에 merge 하는 예제임

### job 설정 전체 내용

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://www.springframework.org/schema/beans
                       http://www.springframework.org/schema/beans/spring-beans-4.0.xsd
                       http://www.springframework.org/schema/batch
                       http://www.springframework.org/schema/batch/spring-batch-3.0.xsd">

    <import resource="abstract/eGovBase.xml"/>

    <job id="davinciCstmrAgreCodeToEC4Job" parent="eGovBaseJob" xmlns="http://www.springframework.org/schema/batch">
        <step id="davinciCstmrAgreCodeToEC4HistStep" parent="eGovBaseStep" next="ec4CstmrAgreCodeHistToEC4Step">
            <tasklet>
                <chunk reader="davinciCstmrAgreCodeItemReader" processor="davinciCstmrAgreCodeItemProcessor"
                    writer="davinciCstmrAgreCodeItemWriter" commit-interval="500"/>
            </tasklet>
        </step>
        <step id="ec4CstmrAgreCodeHistToEC4Step" parent="eGovBaseStep" >
            <tasklet>
                <chunk reader="ec4CstmrAgreCodeHistItemReader" processor="ec4CstmrAgreCodeHistItemProcessor"
                    writer="ec4CstmrAgreCodeHistItemWriter" commit-interval="500"/>
            </tasklet>
        </step>
    </job>

    <bean id="davinciCstmrAgreCodeItemReader" class="org.springframework.batch.item.file.FlatFileItemReader" scope="step">
        <property name="resource" value="file:${source.directory.cstmrAgreCode}/${source.file.cstmrAgreCode}_#{simpleDateFormat3.format(T(java.util.Calendar).getInstance().getTime())}.txt" />
        <property name="lineMapper">
            <bean class="egovframework.rte.bat.core.item.file.mapping.EgovDefaultLineMapper">
                <property name="lineTokenizer">
                    <bean class="egovframework.rte.bat.core.item.file.transform.EgovDelimitedLineTokenizer">
                        <property name="delimiter" value="|"/>
                    </bean>
                </property>
                <property name="objectMapper">
                    <bean class="egovframework.rte.bat.core.item.file.mapping.EgovObjectMapper">
                        <property name="type" value="egovframework.ec4.bat.domain.trade.CstmrAgreCode"/>
                        <property name="names" value="dealerCd,acctCd,acctFrom,acctTo,acctNm,ckCount,grp,srt,titleYn,type,histRegistDe,actionCode"/>
                    </bean>
                </property>
            </bean>
        </property>
    </bean>

    <bean id="davinciCstmrAgreCodeItemWriter" class="org.springframework.batch.item.database.IbatisBatchItemWriter">
        <property name="statementId" value="createDavinciCstmrAgreCodeHist"/>
        <property name="sqlMapClient" ref="sqlMapClient"/>
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <bean id="davinciCstmrAgreCodeItemProcessor" class="egovframework.ec4.bat.domain.trade.CstmrAgreCodeProcessor"/>

    <bean id="ec4CstmrAgreCodeHistItemReader" class="org.springframework.batch.item.database.IbatisPagingItemReader">
        <property name="queryId" value="selectCstmrAgreCodeHist"/>
        <property name="parameterValues">
            <map>
                <entry key="histRegistDe" value="#{simpleDateFormat3.format(T(java.util.Calendar).getInstance().getTime())}"/>
                <entry key="pageSize" value="100"/>
            </map>
        </property>
        <property name="sqlMapClient" ref="sqlMapClient"/>
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <bean id="ec4CstmrAgreCodeHistItemWriter" class="org.springframework.batch.item.database.IbatisBatchItemWriter">
        <property name="statementId" value="mergeCstmrAgreCode"/>
        <property name="sqlMapClient" ref="sqlMapClient"/>
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <bean id="ec4CstmrAgreCodeHistItemProcessor" class="egovframework.ec4.bat.domain.trade.CstmrAgreCodeHistProcessor"/>

</beans>
```

### job 설정
아래 예제는 step을 2개 설정 맨 처음 나오는 setp이 우선 실행되고 next 속성에 있는 setp이 계속 실행됨, 각 스탭은 reader > processor > writer 순서대로 실행됨

```xml
<job id="davinciCstmrAgreCodeToEC4Job" parent="eGovBaseJob" xmlns="http://www.springframework.org/schema/batch">
    <step id="davinciCstmrAgreCodeToEC4HistStep" parent="eGovBaseStep" next="ec4CstmrAgreCodeHistToEC4Step">
        <tasklet>
            <chunk reader="davinciCstmrAgreCodeItemReader" processor="davinciCstmrAgreCodeItemProcessor"
                writer="davinciCstmrAgreCodeItemWriter" commit-interval="500"/>
        </tasklet>
    </step>
    <step id="ec4CstmrAgreCodeHistToEC4Step" parent="eGovBaseStep" >
        <tasklet>
            <chunk reader="ec4CstmrAgreCodeHistItemReader" processor="ec4CstmrAgreCodeHistItemProcessor"
                writer="ec4CstmrAgreCodeHistItemWriter" commit-interval="500"/>
        </tasklet>
    </step>
</job>
```

### reader 설정
resource : 읽어올 파일 위치 지정
lineMapper : 파일에서 읽은 데이타를 VO에 매핑
lineTokenizer : 파일에서 구분자 "|" 를 사용하여 각 항목 구분
objectMapper : 매핑할 VO를 지정하고, VO 필드를 순서대로 기술

```xml
<bean id="davinciCstmrAgreCodeItemReader" class="org.springframework.batch.item.file.FlatFileItemReader" scope="step">
    <property name="resource" value="file:${source.directory.cstmrAgreCode}/${source.file.cstmrAgreCode}_#{simpleDateFormat3.format(T(java.util.Calendar).getInstance().getTime())}.txt" />
    <property name="lineMapper">
        <bean class="egovframework.rte.bat.core.item.file.mapping.EgovDefaultLineMapper">
            <property name="lineTokenizer">
                <bean class="egovframework.rte.bat.core.item.file.transform.EgovDelimitedLineTokenizer">
                    <property name="delimiter" value="|"/>
                </bean>
            </property>
            <property name="objectMapper">
                <bean class="egovframework.rte.bat.core.item.file.mapping.EgovObjectMapper">
                    <property name="type" value="egovframework.ec4.bat.domain.trade.CstmrAgreCode"/>
                    <property name="names" value="dealerCd,acctCd,acctFrom,acctTo,acctNm,ckCount,grp,srt,titleYn,type,histRegistDe,actionCode"/>
                </bean>
            </property>
        </bean>
    </property>
</bean>
```

### writer 설정
데이터를 저장할 insert 문장의 queryId 지정, 나머지는 기본 설정
```xml
<bean id="davinciCstmrAgreCodeItemWriter" class="org.springframework.batch.item.database.IbatisBatchItemWriter">
    <property name="statementId" value="createDavinciCstmrAgreCodeHist"/>
    <property name="sqlMapClient" ref="sqlMapClient"/>
    <property name="dataSource" ref="dataSource"/>
</bean>
```

### processor 설정
데이터 가공이 필요할 때 사용할 bean
```xml
<bean id="davinciCstmrAgreCodeItemProcessor" class="egovframework.ec4.bat.domain.trade.CstmrAgreCodeProcessor"/>
```

## Bean

### 매핑할 VO 생성
egovframework.ec4.bat.domain.trade.CstmrAgreCode
필드를 생성하고 getter/setter 생성
```java
package egovframework.ec4.bat.domain.trade;

import javax.persistence.Entity;
import javax.persistence.Table;

@Entity
@Table(name = "IH_CSTMR_AGRE_CODE")
public class CstmrAgreCode {

    private String dealerCd = "";
    private String acctCd = "";
    private String acctFrom = "";
    private String acctTo = "";
    private String acctNm = "";
    private String ckCount = "";
    private String grp = "";
    private String srt = "";
    private String titleYn = "";
    private String type = "";
    private String histRegistDe = "";
    private String actionCode = "";

    이하 줄임...
```

###  processor 생성

egovframework.ec4.bat.domain.trade.CstmrAgreCodeProcessor
ItemProcessor<IN, OUT>를 구현하고 process 메서드를 override 한다.
process 에서 IN은 메서드의 파라메터 item 이고, OUT은 return 되는 클래스
메서드 안에서 프로그램 성격에 맞게 데이터를 가공하여 return 할 수 있음
아래 예제에서는 가공하지 않고 그대로 return
```java
package egovframework.ec4.bat.domain.trade;

import org.springframework.batch.item.ItemProcessor;

public class CstmrAgreCodeProcessor implements ItemProcessor<CstmrAgreCode, CstmrAgreCode> {

    public CstmrAgreCodeProcessor() {
    }

    @Override
    public CstmrAgreCode process(CstmrAgreCode item) throws Exception {

        return item;
    }
}
```

## 쿼리 작업

/resources/egovframework/sqlmap/ec4/bat/EC4_CstmrAgreCode_SQL_oracle.xml
전체 소스

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE sqlMap PUBLIC "-//iBATIS.com//DTD SQL Map 2.0//EN" "http://ibatis.apache.org/dtd/sql-map-2.dtd">

<sqlMap namespace="CstmrAgreCode">

    <typeAlias alias="cstmrAgreCode" type="egovframework.ec4.bat.domain.trade.CstmrAgreCode"/>

    <resultMap id="result" class="cstmrAgreCode">
		<result property="dealerCd" column="dealer_cd"/>
		<result property="acctCd" column="acct_cd"/>
		<result property="acctFrom" column="acct_from"/>
		<result property="acctTo" column="acct_to"/>
		<result property="acctNm" column="acct_nm"/>
		<result property="ckCount" column="ck_count"/>
		<result property="grp" column="grp"/>
		<result property="srt" column="srt"/>
		<result property="titleYn" column="title_yn"/>
		<result property="type" column="type"/>
		<result property="histRegistDe" column="hist_regist_de"/>
		<result property="actionCode" column="action_code"/>
    </resultMap>

    <select id="selectCstmrAgreCodeHist" resultMap="result">
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
                                dealer_cd
                              , acct_cd
                              , TO_CHAR(acct_from, 'YYYYMMDD') AS acct_from
                              , TO_CHAR(acct_to, 'YYYYMMDD') AS acct_to
                              , acct_nm
                              , ck_count
                              , grp
                              , srt
                              , title_yn
                              , type
                              , TO_CHAR(hist_regist_de, 'YYYYMMDD') AS hist_regist_de
                              , action_code
                          FROM
                                ih_cstmr_agre_code
                         WHERE
                                hist_regist_de = #histRegistDe#
                         ORDER BY
                                dealer_cd, acct_cd
                      ) TB
                 WHERE
                        rownum <= (#_page# + 1) * #_pagesize#
              )
         WHERE
                rn >= #_skiprows# + 1
    ]]>
    </select>


    <insert id="createDavinciCstmrAgreCodeHist" parameterClass="cstmrAgreCode" >
    <![CDATA[
        INSERT INTO ih_cstmr_agre_code
                    (
                      dealer_cd
                    , acct_cd
                    , acct_from
                    , acct_to
                    , acct_nm
                    , ck_count
                    , grp
                    , srt
                    , title_yn
                    , type
                    , hist_regist_de
                    , action_code
                    )
             VALUES
                    (
                      #dealerCd#
                    , #acctCd#
                    , TO_DATE(#acctFrom#, 'YYYYMMDD')
                    , TO_DATE(#acctTo#, 'YYYYMMDD')
                    , #acctNm#
                    , #ckCount#
                    , #grp#
                    , #srt#
                    , #titleYn#
                    , #type#
                    , TO_DATE(#histRegistDe#, 'YYYYMMDD')
                    , #actionCode#
                    )
    ]]>
    </insert>


    <update id="mergeCstmrAgreCode" parameterClass="cstmrAgreCode">
    <![CDATA[
        MERGE INTO
                    if_cstmr_agre_code
             USING
                    dual
                ON (
                         dealer_cd = #dealerCd#
                     AND acct_cd   = #acctCd#
                   )
        WHEN MATCHED THEN
               UPDATE SET
                           acct_from       = TO_DATE(#acctFrom#, 'YYYYMMDD')
                         , acct_to         = TO_DATE(#acctTo#, 'YYYYMMDD')
                         , acct_nm         = #acctNm#
                         , ck_count        = #ckCount#
                         , grp             = #grp#
                         , srt             = #srt#
                         , title_yn        = #titleYn#
                         , type            = #type#
                         , last_updt_pnttm = SYSDATE
                         , last_updusr_id  = 'BATCH_USER'
        WHEN NOT MATCHED THEN
                       INSERT
                             (
                               dealer_cd
                             , acct_cd
                             , acct_from
                             , acct_to
                             , acct_nm
                             , ck_count
                             , grp
                             , srt
                             , title_yn
                             , type
                             , frst_regist_pnttm
                             , frst_register_id
                             , last_updt_pnttm
                             , last_updusr_id
                             )
                       VALUES
                             (
                               #dealerCd#
                             , #acctCd#
                             , TO_DATE(#acctFrom#, 'YYYYMMDD')
                             , TO_DATE(#acctTo#, 'YYYYMMDD')
                             , #acctNm#
                             , #ckCount#
                             , #grp#
                             , #srt#
                             , #titleYn#
                             , #type#
                             , SYSDATE
                             , 'BATCH_USER'
                             , SYSDATE
                             , 'BATCH_USER'
                             )
    ]]>
    </update>

</sqlMap>
```

작성중...
