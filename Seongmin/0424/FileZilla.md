# FTP란?

File Transfer Protocol

사용자 PC와 호스팅 서버 간 파일을 송수신 해주는 프로그램



# FileZilla

- 빠른 파일 전송 속도
- 무료
- FTP뿐만 아니라 FTPS(FTP-SSL), SFTP(SSH-FTP) 지원
- 드래그 앤 드랍 방식으로 간단하게 파일이나 폴더 옮기기 가능



## FileZilla with PEM

FileZilla에서는 pem 키를 활용해 호스팅 서버에 접근 권한을 얻을 수 있습니다.

[1] FileZilla 실행

[2] 왼쪽 상단 [편집] > [설정] > [SFTP] > [키 파일 추가]

[3] 왼쪽 상단 [파일] > [사이트 관리자] > [새 사이트]

- 프로토콜: SFTP - SSH File Transfer Protocol

- 호스트: {SERVER IP}         (ex: xxx.xxx.xxx.xxx)
- 로그온 유형:비밀번호 묻기
- 사용자: {USER}                  (ex: ubuntu)

[4] [연결]