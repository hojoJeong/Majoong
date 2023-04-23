쿠버네티스는 Dash Board를 제공하여 실습할 때 사용하기 편리하다. 그러나, 실제 보안적인 측면에서 중요한 정보들이 다 드러나기 때문에 서비스를 운영할 때에는 Dash Board 활용하는 것을 권장하지 않는다고 한다.



Pod 생성

```
apiVersion: v1
kind: Pod
metadata:
	name: hello-pod
	labels:
		app: hello
spec:
	containers:
		-name: hello-container
	image: hsm2358/hello
	ports:
		- containerPort: 8000
	
```



Service생성

```
apiVersion: v1
kind: Service
metadata:
	name: hello-svc
spec:
	selector:
		app: hello
	ports:
		- port:8200
		targetPort: 8000
	externalIPs:
		- xxx.xxx.xxx.xxx
		
```

