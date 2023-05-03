find 명령어에 -mtime +일수 옵션을 주면 되는데 생각한 일수보다 1 적게 주어야 합니다.

예) 3일 초과한 파일을 삭제하려면 -mtime +2 -delete

예 3분을 초과한 파일을 삭제하려면 -mmin +2 -delete



```
find /opt/openvidu/recordings/ find -name "*" -mmin +330 -delete
```

/opt/openvidu/recordings 디렉토리 내에 수정된지 330분 이상 된 모든 파일을 삭제한다.



```
[옵션]

-maxdepth

찾을 파일들의 경로 depth(깊이)를 지정한다. 1은 현재 2는 현재디렉토리위 한단계 아래의 하부 디렉토리 포함 이런식(옵션의 맨 처음에 와야 함)

 -depth 

찾을 파일들의 경로 depth(깊이)를 지정한다. 뒤의 단계지정은 maxdepth와 동일한데 다른건 maxdepth는 지정한 depth안의 파일을 모두 보여주지만 depth는 지정한 단계의 파일들만 보여줌

-name filename
파일 이름으로 찾는다.
-atime +n
access time 이 n일 이전인 파일을 찾는다.
-atime -n
access time이 n일 이내인 파일을 찾는다.
-mtime +n
n일 이전에 변경된 파일을 찾는다.
-mtime -n
n일 이내에 변경된 파일을 찾는다.
-perm nnn
파일 권한이 nnn인 파일을 찾는다.
-type x
파일 타입이 x인 파일들을 찾는다.(f: file, d: directory)
-size n
사이즈가 n이상인 파일들을 찾는다.
-links n
링크된 개수가 n인 파일들을 찾는다.
-user username
user이름으로 찾는다.
-group groupname
group 이름으로 찾는다.

처리방법 : 찾은 파일을 어떻게 할 것인지를 지정한다.
-print
찾은 파일의 절대 경로명을 화면에 출력한다.
-ls

찾은 내용을 ls처럼 보여줌

-exec cmd {};　
찾은 파일들에 대해 cmd 명령어를 실행한다.
```



