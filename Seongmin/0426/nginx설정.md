## SSL 인증서 등록

### Let's Encrypt 작동 원리

```
인증서를 발급하기 전에 Let’s Encrypt는 도메인 소유권을 확인합니다. 호스트에서 실행되는 Let’s Encrypt 클라이언트는 필요한 정보가 포함된 임시 파일(토큰)을 생성합니다. 그런 다음 Let’s Encrypt 유효성 검사 서버는 HTTP 요청을 만들어 파일을 검색하고 토큰의 유효성을 검사합니다. 그러면 도메인의 DNS 레코드가 Let’s Encrypt 클라이언트를 실행하는 서버로 확인되는지 확인합니다.
```



### 전제 조건

- Nginx 또는 Nginx Plus 설치
- 도메인 이름을 소유해야함
- 도메인 이름과 서버의 공용 IP 주소를 연결하는 DNS 레코드 생성 (AWS-가비아 도메인 연결편 확인)



### Let's Encrypt 클라이언트 다운로드

Ubuntu 18.04 이상 기준

```
$ apt-get update
$ sudo apt-get install certbot
$ apt-get install python3-certbot-nginx
```



### Nginx SSL 설정

- 텍스트 편집기를 사용하여 /etc/nginx/conf.d 디렉토리에 domain-name.conf 라는 파일을 만듭니다. (예시: majoong.conf)

  ```
  server {
      listen 80 default_server;
      listen [::]:80 default_server;
      root /var/www/html;
      server_name majoong4u.com;
  }
  ```



### SSL/TLS 인증서 받기

```
$ sudo certbot --nginx -d example.com -d www.example.com
```





## majoong.conf

```
server {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Proto $scheme;

        #Websocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        error_page 405 = $uri;

        location /{
                proxy_pass http://localhost:8090;
        }

    listen 443 ssl; # managed by Certbot
    server_name i8d204.p.ssafy.io;
    ssl_certificate /etc/letsencrypt/live/majoong4u.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/majoong4u.com/privkey.pem; # managed by Certbot

    #include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}


server {
    if ($host = majoong4u.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

        listen 80;
        server_name majoong4u.com;
    return 404; # managed by Certbot
}
```



### Let's Encrypt 인증서 자동 갱신

- crontab 파일을 엽니다

  ```
  $ crontab -e
  ```

- `certbot` 매일 실행할 명령을 추가합니다 .

  ```
  0 12 * * * /usr/bin/certbot renew --quiet
  ```

- 파일을 저장하고 닫습니다. 설치된 모든 인증서가 자동으로 갱신되고 다시 로드됩니다.