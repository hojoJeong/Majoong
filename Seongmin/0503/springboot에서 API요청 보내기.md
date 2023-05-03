RestTemplate를 활용하여 Springboot에서 API요청 보내기!



### DELETE 요청(Method만 바꾸면 Get과 비슷)

녹화파일을 지우는 메서드를 작성하였습니다. 입력받은 recordingId을 PathVariable 형태로 입력하여 요청을 보냅니다.

요청 순서는 아래와 같습니다.

1. RestTemplate 인스턴스를 생성

2. Header 생성
3. Header로 entity 생성
4. restTemplate.exchange()에 url, method, requestEntity, responseType을 담아 요청을 보냅니다.

```java
public void removeRecording(String recordingId) {
        String url = OPENVIDU_BASE_PATH + "recordings/" + recordingId;

        // OPENVIDU REST API 요청
        RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());
        // Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.add("Authorization", "Basic " + OPENVIDU_SECRET);

        HttpEntity<String> entity = new HttpEntity<String>("", headers);
        // request
        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    url, //{요청할 서버 주소}
                    HttpMethod.DELETE, //{요청할 방식}
                    entity, // {요청할 때 보낼 데이터}
                    String.class
            );
        }
        catch (HttpClientErrorException | HttpServerErrorException e){
            HttpStatus statusCode = e.getStatusCode();

            if (statusCode == HttpStatus.NOT_FOUND){        //404: 삭제할 녹황파일이 없는 경우
                throw new NotExistRecordingException();
            }
            else if (statusCode == HttpStatus.CONFLICT) {   //409: 녹화가 진행중인 경우
                throw new RecordingInProgressException();
            }
        }

    }
```





### POST 요청

세션을 초기화하는 메서드를 작성하였습니다. 순서는 아래와 같습니다.

1. RestTemplate 인스턴스를 생성

2. Header 생성
3. Body 생성
4. Header, Body로 entity 생성
5. restTemplate.exchange()에 url, method, requestEntity, responseType을 담아 요청을 보냅니다.
6. response를 가공합니다.

```java
public InitializeSessionResponseDto initializeSession(HttpServletRequest request){
        ...(생략)

        String url = OPENVIDU_BASE_PATH + "sessions";
        String customSessionId = userId + "-" + System.currentTimeMillis();
        String recordingMode = "ALWAYS";

        // OPENVIDU REST API 요청
        RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());
        
        // Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.add("Authorization", "Basic " + OPENVIDU_SECRET);
        
        // Body 생성
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("customSessionId",customSessionId);
        jsonObject.addProperty("recordingMode",recordingMode);
        
        // Header + Body
        HttpEntity<String> entity = new HttpEntity<String>(jsonObject.toString(), headers);
        
        // request
        ResponseEntity<String> response = restTemplate.exchange(
                url, //{요청할 서버 주소}
                HttpMethod.POST, //{요청할 방식}
                entity, // {요청할 때 보낼 데이터}
                String.class
        );

        // response
        JsonParser parser = new JsonParser();
        JsonObject responseBody = parser.parse(response.getBody()).getAsJsonObject();
        String sessionId = responseBody.get("id").getAsString();

        InitializeSessionResponseDto responseDto = new InitializeSessionResponseDto();
        responseDto.setSessionId(sessionId);
        return responseDto;
    }
```