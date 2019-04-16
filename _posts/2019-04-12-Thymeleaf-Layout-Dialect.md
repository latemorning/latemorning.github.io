---
layout:   post
title:    Spring Boot Thymeleaf Layout Dialect 사용하기
author:   harry
tags:     [Spring Boot, Thymeleaf, Layout, Dialect]
comments: true
published : true
---

## STS Spring Boot Thymeleaf Layout 셋팅
Bootstrap 3 기반의 관리자 템플릿 중 gentelella 템플릿을 이용하여 Thymeleaf로 Layout을 잡아보겠습니다.

### gentelella 템플릿
아래 화면을 top, left, footer, content로 나눕니다.
![img_03](/images/2019-04-12-Thymeleaf-Layout-Dialect/img_03.png)

### gentelella 템플릿 다운로드
https://github.com/ColorlibHQ/gentelella 에서 초록색 Clone or download 버튼을 눌러서 zip파일로 다운받습니다.

### 탬플릿 확인
아래와 같은 구조로 되어있습니다. production 폴더에 있는 index.html 파일을 열어보면 전체적인 템플릿을 확인할 수 있습니다.
![img_04](/images/2019-04-12-Thymeleaf-Layout-Dialect/img_04.png)

### 프로젝트 생성
STS 기준으로 설명합니다.

단축키 Alt + Shift + N, Spring Starter Project 선택
![img_01](/images/2019-04-12-Thymeleaf-Layout-Dialect/img_01.png)

JPA와 MySQL은 선택하지 않습니다. 선택했다면 주석처리하거나 application.properties에 관련 설정을 입력해줍니다.
![img_02](/images/2019-04-12-Thymeleaf-Layout-Dialect/img_02.png)

프로젝트가 생성될때까지 조금 기다리면 아래와 같은 구조의 프로젝트가 생성됩니다.
![img_05](/images/2019-04-12-Thymeleaf-Layout-Dialect/img_05.png)

#### application.properties 설정
캐시 기능은 잠시 꺼둡니다.
```properties
spring.thymeleaf.cache=false
```

#### 이클립 Thymeleaf 플러그인 설치
개발 편의를 위해 아래 플러그인을 설치합니다.
Thymeleaf - http://www.thymeleaf.org/eclipse-plugin-update-site/

#### thymeleaf-layout-dialect 라이브러리 추가
thymeleaf로 레이아웃을 설정하기위한 라이브러리 build.gradle에 추가
compile group: 'nz.net.ultraq.thymeleaf', name: 'thymeleaf-layout-dialect'
```
dependencies {
	implementation 'org.springframework.boot:spring-boot-starter-thymeleaf'
	implementation 'org.springframework.boot:spring-boot-starter-web'
	compileOnly 'org.projectlombok:lombok'
	runtimeOnly 'org.springframework.boot:spring-boot-devtools'
	annotationProcessor 'org.projectlombok:lombok'
	providedRuntime 'org.springframework.boot:spring-boot-starter-tomcat'
	testImplementation 'org.springframework.boot:spring-boot-starter-test'
	compile group: 'nz.net.ultraq.thymeleaf', name: 'thymeleaf-layout-dialect'
}
```

추가후 아래와 같이 build.gradle파일 우클릭후 그리과 같이 선택하여 라이브러리 추가
![img_06](/images/2019-04-12-Thymeleaf-Layout-Dialect/img_06.png)

#### gentelella 템플릿 추가 및 최종 thymeleaf 템플릿 확인
src/main/resources/static 폴더아래 압축해제한 gentelella 템플릿 파일을 복사합니다.
static 폴더는 spring boot에서 정적 자원이 위치하는 폴더입니다.
src/main/resources/templates 폴더는 동적인 자원이 위치하는 폴더입니다.
아래 이미지가 최종 완성된 형태의 구조입니다.
* vendors 하위 폴더는 파일이 많아서 아래 그림과 같이 5개 폴더만 골라서 복사했습니다. 나중에 필요한 파일은 따로 복사해서 사용하면 됩니다.
![img_07](/images/2019-04-12-Thymeleaf-Layout-Dialect/img_07.png)

#### 폴더 생성
templates 폴더 아래 fragments, layout, sample 3개 폴더를 생성합니다.


#### 전체 레이아웃(화면)
production/plain_page.html 파일을 브라우져로 열어보면 아래와 같은 화면이 열립니다.
아래 화면을 기준으로 작업을 시작해 보겠습니다.
![img_08](/images/2019-04-12-Thymeleaf-Layout-Dialect/img_08.png)


### Controller
간단한 Controller를 생성합니다. plain.html파일을 보여줍니다.
```java
package com.pet.sample.cmm.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SampleController {

    @GetMapping("/sample/plain")
    public void plain() {

        System.out.println("/sample/plain");
    }
}
```


### 각 페이지 소스

#### layout.html
페이지 전체에서 사용되는 공통 레이아웃입니다. plain_page.html 파일 내용 전체를 붙여넣고 단계별로 각 파일을 분리합니다.
```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org" xmlns:layout="http://www.ultraq.net.nz/thymeleaf/layout">

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <!-- Meta, title, CSS, favicons, etc. -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!-- title -->
        <title layout:title-pattern="$CONTENT_TITLE :: $LAYOUT_TITLE">sample</title>
        <!-- /title -->

        <!-- Bootstrap -->
        <link th:href="@{/vendors/bootstrap/dist/css/bootstrap.min.css}" rel="stylesheet">
        <!-- Font Awesome -->
        <link th:href="@{/vendors/font-awesome/css/font-awesome.min.css}" rel="stylesheet">
        <!-- NProgress -->
        <link th:href="@{/vendors/nprogress/nprogress.css}" rel="stylesheet">

        <!-- Custom Theme Style -->
        <link th:href="@{/build/css/custom.min.css}" rel="stylesheet">

        <!-- 사용자 스타일 영역 -->
        <th:block layout:fragment="user-style"></th:block>
    </head>

<body class="nav-md">
    <div class="container body">
        <div class="main_container">

            <!-- left menu -->
            <div th:replace="~{fragments/left::leftFragment}"></div>
            <!-- left menu -->

            <!-- top navigation -->
            <div th:replace="~{fragments/top::topFragment}"></div>
            <!-- /top navigation -->

            <!-- page content -->
            <div th:replace="~{fragments/content::contentFragment}"></div>
            <!-- /page content -->

            <!-- footer content -->
            <footer th:replace="~{fragments/footer::footerFragment}"></footer>
            <!-- /footer content -->

        </div>
    </div>

        <!-- jQuery -->
        <script th:src="@{/vendors/jquery/dist/jquery.min.js}"></script>
        <!-- Bootstrap -->
        <script th:src="@{/vendors/bootstrap/dist/js/bootstrap.min.js}"></script>
        <!-- FastClick -->
        <script th:src="@{/vendors/fastclick/lib/fastclick.js}"></script>
        <!-- NProgress -->
        <script th:src="@{/vendors/nprogress/nprogress.js}"></script>

        <!-- Custom Theme Scripts -->
        <script th:src="@{/build/js/custom.min.js}"></script>

        <!-- 사용자 스크립트 영역 -->
        <th:block layout:fragment="user-script"></th:block>

</body>
</html>
```

#### left.html
layout.html 에서 left 메뉴 부분을 잘라서 생성했습니다.
```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">

<div class="col-md-3 left_col" th:fragment="leftFragment">
    <div class="left_col scroll-view">
        <div class="navbar nav_title" style="border: 0;">
            <a href="index.html" class="site_title"><i class="fa fa-paw"></i> <span>Gentelella Alela!</span></a>
        </div>

        <div class="clearfix"></div>

        <!-- menu profile quick info -->
        <div class="profile clearfix">
            <div class="profile_pic">
                <img th:src="@{production/images/img.jpg}" alt="..." class="img-circle profile_img">
            </div>
            <div class="profile_info">
                <span>Welcome,</span>
                <h2>John Doe</h2>
            </div>
            <div class="clearfix"></div>
        </div>
        <!-- /menu profile quick info -->

        <br />

        <!-- sidebar menu -->
        <div id="sidebar-menu" class="main_menu_side hidden-print main_menu">
            <div class="menu_section">
                <h3>General</h3>
                <ul class="nav side-menu">
                    <li><a><i class="fa fa-home"></i> Home <span class="fa fa-chevron-down"></span></a>
                        <ul class="nav child_menu">
                            <li><a href="index.html">Dashboard</a></li>
                            <li><a href="index2.html">Dashboard2</a></li>
                            <li><a href="index3.html">Dashboard3</a></li>
                        </ul></li>
                    <li><a><i class="fa fa-edit"></i> Forms <span class="fa fa-chevron-down"></span></a>
                        <ul class="nav child_menu">
                            <li><a href="form.html">General Form</a></li>
                            <li><a href="form_advanced.html">Advanced Components</a></li>
                            <li><a href="form_validation.html">Form Validation</a></li>
                            <li><a href="form_wizards.html">Form Wizard</a></li>
                            <li><a href="form_upload.html">Form Upload</a></li>
                            <li><a href="form_buttons.html">Form Buttons</a></li>
                        </ul></li>
                    <li><a><i class="fa fa-desktop"></i> UI Elements <span class="fa fa-chevron-down"></span></a>
                        <ul class="nav child_menu">
                            <li><a href="general_elements.html">General Elements</a></li>
                            <li><a href="media_gallery.html">Media Gallery</a></li>
                            <li><a href="typography.html">Typography</a></li>
                            <li><a href="icons.html">Icons</a></li>
                            <li><a href="glyphicons.html">Glyphicons</a></li>
                            <li><a href="widgets.html">Widgets</a></li>
                            <li><a href="invoice.html">Invoice</a></li>
                            <li><a href="inbox.html">Inbox</a></li>
                            <li><a href="calendar.html">Calendar</a></li>
                        </ul></li>
                    <li><a><i class="fa fa-table"></i> Tables <span class="fa fa-chevron-down"></span></a>
                        <ul class="nav child_menu">
                            <li><a href="tables.html">Tables</a></li>
                            <li><a href="tables_dynamic.html">Table Dynamic</a></li>
                        </ul></li>
                    <li><a><i class="fa fa-bar-chart-o"></i> Data Presentation <span class="fa fa-chevron-down"></span></a>
                        <ul class="nav child_menu">
                            <li><a href="chartjs.html">Chart JS</a></li>
                            <li><a href="chartjs2.html">Chart JS2</a></li>
                            <li><a href="morisjs.html">Moris JS</a></li>
                            <li><a href="echarts.html">ECharts</a></li>
                            <li><a href="other_charts.html">Other Charts</a></li>
                        </ul></li>
                    <li><a><i class="fa fa-clone"></i>Layouts <span class="fa fa-chevron-down"></span></a>
                        <ul class="nav child_menu">
                            <li><a href="fixed_sidebar.html">Fixed Sidebar</a></li>
                            <li><a href="fixed_footer.html">Fixed Footer</a></li>
                        </ul></li>
                </ul>
            </div>
            <div class="menu_section">
                <h3>Live On</h3>
                <ul class="nav side-menu">
                    <li><a><i class="fa fa-bug"></i> Additional Pages <span class="fa fa-chevron-down"></span></a>
                        <ul class="nav child_menu">
                            <li><a href="e_commerce.html">E-commerce</a></li>
                            <li><a href="projects.html">Projects</a></li>
                            <li><a href="project_detail.html">Project Detail</a></li>
                            <li><a href="contacts.html">Contacts</a></li>
                            <li><a href="profile.html">Profile</a></li>
                        </ul></li>
                    <li><a><i class="fa fa-windows"></i> Extras <span class="fa fa-chevron-down"></span></a>
                        <ul class="nav child_menu">
                            <li><a href="page_403.html">403 Error</a></li>
                            <li><a href="page_404.html">404 Error</a></li>
                            <li><a href="page_500.html">500 Error</a></li>
                            <li><a href="plain_page.html">Plain Page</a></li>
                            <li><a href="login.html">Login Page</a></li>
                            <li><a href="pricing_tables.html">Pricing Tables</a></li>
                        </ul></li>
                    <li><a><i class="fa fa-sitemap"></i> Multilevel Menu <span class="fa fa-chevron-down"></span></a>
                        <ul class="nav child_menu">
                            <li><a href="#level1_1">Level One</a>
                            <li><a>Level One<span class="fa fa-chevron-down"></span></a>
                                <ul class="nav child_menu">
                                    <li class="sub_menu"><a href="level2.html">Level Two</a></li>
                                    <li><a href="#level2_1">Level Two</a></li>
                                    <li><a href="#level2_2">Level Two</a></li>
                                </ul></li>
                            <li><a href="#level1_2">Level One</a></li>
                        </ul></li>
                    <li><a href="javascript:void(0)"><i class="fa fa-laptop"></i> Landing Page <span class="label label-success pull-right">Coming Soon</span></a></li>
                </ul>
            </div>

        </div>
        <!-- /sidebar menu -->

        <!-- /menu footer buttons -->
        <div class="sidebar-footer hidden-small">
            <a data-toggle="tooltip" data-placement="top" title="Settings"> <span class="glyphicon glyphicon-cog" aria-hidden="true"></span>
            </a> <a data-toggle="tooltip" data-placement="top" title="FullScreen"> <span class="glyphicon glyphicon-fullscreen" aria-hidden="true"></span>
            </a> <a data-toggle="tooltip" data-placement="top" title="Lock"> <span class="glyphicon glyphicon-eye-close" aria-hidden="true"></span>
            </a> <a data-toggle="tooltip" data-placement="top" title="Logout" href="login.html"> <span class="glyphicon glyphicon-off" aria-hidden="true"></span>
            </a>
        </div>
        <!-- /menu footer buttons -->
    </div>
</div>

</html>
```

#### top.html
layout.html 에서 top 부분을 잘랐습니다.
```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">

<div class="top_nav" th:fragment="topFragment">
    <div class="nav_menu">
        <nav>
            <div class="nav toggle">
                <a id="menu_toggle"><i class="fa fa-bars"></i></a>
            </div>

            <ul class="nav navbar-nav navbar-right">
                <li class=""><a href="javascript:;" class="user-profile dropdown-toggle" data-toggle="dropdown" aria-expanded="false"> <img th:src="@{/production/images/img.jpg}" alt="">John Doe <span
                        class=" fa fa-angle-down"></span>
                </a>
                    <ul class="dropdown-menu dropdown-usermenu pull-right">
                        <li><a href="javascript:;"> Profile</a></li>
                        <li><a href="javascript:;"> <span class="badge bg-red pull-right">50%</span> <span>Settings</span>
                        </a></li>
                        <li><a href="javascript:;">Help</a></li>
                        <li><a href="login.html"><i class="fa fa-sign-out pull-right"></i> Log Out</a></li>
                    </ul></li>

                <li role="presentation" class="dropdown"><a href="javascript:;" class="dropdown-toggle info-number" data-toggle="dropdown" aria-expanded="false"> <i class="fa fa-envelope-o"></i>
                        <span class="badge bg-green">6</span>
                </a>
                    <ul id="menu1" class="dropdown-menu list-unstyled msg_list" role="menu">
                        <li><a> <span class="image"><img src="images/img.jpg" alt="Profile Image" /></span> <span> <span>John Smith</span> <span class="time">3 mins ago</span>
                            </span> <span class="message"> Film festivals used to be do-or-die moments for movie makers. They were where... </span>
                        </a></li>
                        <li><a> <span class="image"><img src="images/img.jpg" alt="Profile Image" /></span> <span> <span>John Smith</span> <span class="time">3 mins ago</span>
                            </span> <span class="message"> Film festivals used to be do-or-die moments for movie makers. They were where... </span>
                        </a></li>
                        <li><a> <span class="image"><img src="images/img.jpg" alt="Profile Image" /></span> <span> <span>John Smith</span> <span class="time">3 mins ago</span>
                            </span> <span class="message"> Film festivals used to be do-or-die moments for movie makers. They were where... </span>
                        </a></li>
                        <li><a> <span class="image"><img src="images/img.jpg" alt="Profile Image" /></span> <span> <span>John Smith</span> <span class="time">3 mins ago</span>
                            </span> <span class="message"> Film festivals used to be do-or-die moments for movie makers. They were where... </span>
                        </a></li>
                        <li>
                            <div class="text-center">
                                <a> <strong>See All Alerts</strong> <i class="fa fa-angle-right"></i>
                                </a>
                            </div>
                        </li>
                    </ul></li>
            </ul>
        </nav>
    </div>
</div>

</html>
```

#### content.html
layout.html 에서 content 부분을 잘랐습니다.
```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" xmlns:layout="http://www.ultraq.net.nz/thymeleaf/layout">

<div class="right_col" role="main" th:fragment="contentFragment">
    <div class="">
        <div class="page-title">
            <div class="title_left">
                <h3>Plain Page</h3>
            </div>

            <div class="title_right">
                <div class="col-md-5 col-sm-5 col-xs-12 form-group pull-right top_search">
                    <div class="input-group">
                        <input type="text" class="form-control" placeholder="Search for..."> <span class="input-group-btn">
                            <button class="btn btn-default" type="button">Go!</button>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="clearfix"></div>

        <div class="row">
            <div class="col-md-12 col-sm-12 col-xs-12">
                <div class="x_panel">
                    <div class="x_title">
                        <h2>Plain Page</h2>
                        <ul class="nav navbar-right panel_toolbox">
                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a></li>
                            <li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><i class="fa fa-wrench"></i></a>
                                <ul class="dropdown-menu" role="menu">
                                    <li><a href="#">Settings 1</a></li>
                                    <li><a href="#">Settings 2</a></li>
                                </ul></li>
                            <li><a class="close-link"><i class="fa fa-close"></i></a></li>
                        </ul>
                        <div class="clearfix"></div>
                    </div>
                    <div class="x_content">Add content to the page ...</div>
                </div>
            </div>
        </div>
    </div>
</div>
```

#### footer.html
layout.html 에서 footer부분을 잘랐습니다.
```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">

<footer th:fragment="footerFragment">
    <div class="pull-right">
        Gentelella - Bootstrap Admin Template by <a href="https://colorlib.com">Colorlib</a>
    </div>
    <div class="clearfix"></div>
</footer>

</html>
```

#### plain.html
실제 개발하는 소스입니다. 위에서 만든 레이아웃에 layout:fragment 이름이 같은 위치에 실제 소스내용이 반영됩니다.
```html
<html xmlns:th="http://www.thymeleaf.org" xmlns:layout="http://www.ultraq.net.nz/thymeleaf/layout" layout:decorate="~{layout/layout}">

<head>

    <!-- title -->
    <title>plain</title>
    <!-- /title -->

    <!-- 사용자 style -->
    <th:block layout:fragment="userStyle">
        <style>
        </style>
    </th:block>
    <!-- /style -->

</head>

<body>

    <!-- content title -->
    <div class="title_left" layout:fragment="contentTitle">
        <h3>Plain Page2</h3>
    </div>
    <!-- /content title -->


    <!-- content body -->
    <div class="col-md-12 col-sm-12 col-xs-12" layout:fragment="contentBody">
        plain page
    </div>
    <!-- /content body -->


    <!-- 사용자 script -->
    <th:block layout:fragment="userScript">
        <script>
        </script>
    </th:block>
    <!-- /script -->

</body>
</html>
```
