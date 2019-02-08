---
layout:   post
title:    Windows에서 python, Django 설치
author:   harry
tags:     [Windows, python, django]
comments: false
---
<!-- Start Writing Below in Markdown -->

이 문서는 [https://developer.mozilla.org/ko/docs/Learn/Server-side/Django/development_environment](https://developer.mozilla.org/ko/docs/Learn/Server-side/Django/development_environment) 를 참고하였음

## Windows python 설치
1. 다음 링크에서 최신버전 다운로드 [https://www.python.org/downloads/](https://www.python.org/downloads/)

2. 다운로드한 파일을 더블클릭하여 설치
python3 설치확인
```
py -3 -V
 Python 3.7.1
```
설치되 패키지 목록 확인
```
pip3 list
```

## 가상환경 virtualenvwrapper-win 설치

1. 아래 명령 실행하면 설치 끝
```
pip3 install virtualenvwrapper-win
```
2. 가상환경 생성하기
```
mkvirtualenv my_django_environment
```
![django_01](/images/django/django_01.png)

3. 자주 사용하게될 명령어
- deactivate — 활성화된 파이썬 가상 환경을 비활성화한다
- workon — 사용가능한 가상 환경 목록을 보여준다
- workon name_of_environment — 특정 파이썬 가상 환경을 활성화한다
- rmvirtualenv name_of_environment — 특정 환경을 제거한다.

## Django 설치하기
1. 가상환경을 생성하고, workon 명령으로 가상환경 진입 후 pip3를 사용하여 설치
```
pip3 install django
```

2. Django 설치 확인
```
py -m django --version
```
![django_02](/images/django/django_02.png)
