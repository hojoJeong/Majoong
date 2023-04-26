## Redis : REmote DIctionary Storage
* 메모리 기반의 데이터 저장소
* 메모리 기반이므로 휘발성
* single thread
* key-value 형식으로 저장
* 초당 5 ~ 25만 request 실행가능

### 목적
* 주로 caching 을 목적으로 사용
* 데이터가 큰 경우, DB에서 조회하는 부분을 메모리에 캐싱하여 성능 향상
* 캐싱할 데이터는 update가 자주 되지 않는 정적인 데이터 사용이 효과적
* 너무 많은 update가 일어나면, DB와의 sync 비용 발생
* Redis 사용시 반드시 failover 고려
  * Redis 장애시 DB에서 검색
  * Redis 이중화 및 백업

### 장점
* Read, Write 속도가 빠르다
* 다양한 타입의 아키텍쳐 제공
  * Single, Master-Slave, Sentinel, Cluster
* partitioning

### 단점
* 휘발성
* single thread
* Big size data에 비적합

### String 자료구조
* key-value 구조
```
$ keys *
$ set key value
$ get key
$ del key
```

### Hash 자료구조
* key-subkey-value
```
$ hgetall key
$ hget key subkey value
$ hget key subkey
```

### geospatial 자료구조
* geoadd 로 좌표정보 저장
* geodist 로 두 좌표간 거리
* georadius 로 특정 좌표 특정 반경 안의 좌표 구하기
```
$ geoadd key longitude latitude member [longitude latitude member ...]
$ geodist key member1 member2 [unit]                                                // default는 m, 필요시 단위 직접 작성 ex) km
$ georadius key longitude latitude radius 10km withdist withcoord asc count 3
```