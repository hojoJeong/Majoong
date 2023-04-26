# VM 구조

Host Server

Host OS

Hypervisor

Guest OS

Application



# Container 구조

Host Server

Host OS

container

Application



# VM과 Container의 차이

- VM은 각각의 OS를 띄워야하는 구조이고, Container는 한 OS를 공유를 하는 개념이다. 부팅 속도 등을 따졌을 때 속도면에서 Container가 유리하다.

- VM은 Host OS에 관계없이 이종의 OS를 설치할 수 있지만, Container는 그럴 수 없다.

- 보안적인 측면에서 VM은 Guest OS가 뚫려도 다른 Guest OS, Host OS와는 완벽히 분리되어있기 때문에 각각의 VM끼리 피해가 가지 않지만, 한 Container가 뚫리면 다른 Container도 뚫릴 우려가 있다.

- 한 서비스를 Module A, B, C로 구성한다고 할 때, VM은 동일한 언어로 Module을 구성하며, C모듈에 특히 부하가 심한 상황에는 VM을 하나 더 생성해서 띄워야 한다. A, B는 사실상 확장이 필요없는데 패키지이기 때문에 추가되며, VM을 구성하는 Guest OS도 추가해야하므로 비효율적이다. 반면, 컨테이너를 활용하면 각각의 모듈을 최적하기위해 서로 다른 언어로 개발할 수 있으며, 모듈을 분리해서 서비스하는 MSA구조를 가질 수 있다. 쿠버네티스는 pod단위로 배포단위를 가지는데, A와 B를 한 pod에 넣고, C를 다른 pod에 넣은 상태로 구성할 수 있다. C모듈에 부하가 심하다면 C를 담고있는 pod만 확장하면 되므로 훨씬 효율적이다.



# 호스트 자원 분리하는 리눅스의 고유 기술

namespace: 커널에 관련된 영역 분리(mnt, pid, net, ipc, uts, user)

cgroups: 자원에 관련된 영역을 분리(memory, CPU, I/O, network)





