---

layout: post title: Atom 셋팅 author: harry tags: [editor, atom, setting] comments: true

published : true
----------------

Atom 에디터 셋팅
----------------

### 플러그인

###### emmet

소스 자동완성기능

###### Remote-FTP

ftp 클라이언트, 단축키는 Alt + Ctrl + O

###### atom-beautify

소스코드 라인 정렬, 사용은 우클릭 - Debug Atom Beautify 클릭

###### tool-bar

툴바 아이콘

###### highlight-line

선택한 코드의 행을 밝게 보여줌

###### minimap

코드의 미니맵 보여줌 설정에서 absolute-mode 활성 권장

### 테마

###### atom-monokai

### 참고 사이트

https://futurecreator.github.io/2016/06/14/atom-as-markdown-editor/

### atom에서 설치가 되지 않을때

https://atom.io/packages 사이트에서 해당 플러그인 검색

```
cd ~/.atom/packages
git clone https://github.com/emmetio/emmet-atom
cd emmet-atom
npm install
```

-	github에 있는 clone url 전체 복사
-	npm이 실행되지 않을때는 node.js 설치한다.
-	npm 업데이트시 https 차단됐을때 아래처럼 주소를 변경한다.
	-	`npm config set registry http://registry.npmjs.org/ --global`
