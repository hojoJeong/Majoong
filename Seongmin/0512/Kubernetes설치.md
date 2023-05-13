1. Xshell 설치: 생성될 Master/Woker Node에 접속할 툴 (기존에 쓰고 있는게 있으면 생략가능)

   - https://www.netsarang.com/en/free-for-home-school/
   - 이름 / 이메일 / Xshell Only -> DOWNLOAD
   - 이메일에서 다운로드 링크 클릭
   - k8s master/worker node 생성
     - k8s-master , host: 192.168.56.30:22
     - k8s-worker1, host: 192.168.56.31:22
     - k8s-worker2, host: 192.168.56.32:22

2. VirtualBox 설치: VM 및 내부 네트워크 생성 툴

   - 6.1.26 버전 다운로드: https://download.virtualbox.org/virtualbox/6.1.26/VirtualBox-6.1.26-145957-Win.exe
   - 다운로드 사이트: https://www.virtualbox.org/wiki/Downloads

3. Vagrant 설치 및 k8s 설치 스크립트 실행: 자동으로 VirtualBox를 이용해 VM들을 생성하고, k8s 관련 설치 파일들이 실행됨

   3-1) 설치

   - 2.2.18 버전 다운로드: https:/releases.hashicorp.com/vagrant/2.2.18/vagrant_2.2.18_x86_64.msi
   - 다운로드 사이트: https://www.vagrantup.com/downloads

   3-2) Vagrant 명령 실행

   - 윈도우에서 cmd 실행
   - k8s 폴더 생성 및 이동
   - Vagrantfile 파일 다운로드

   ```
   mkdir k8s
   cd k8s
   curl -O https://kubetm.github.io/yamls/k8s-install/Vagrantfile
   ```

   - Vagrant 실행(5-10분 소요)

   ```
   vagrant up
   ```

   > Vagrant 명령어 참고
   >
   > vagrant up: 가상머신 기동
   >
   > vagrant halt: 가상머신 Shutdown
   >
   > vagrant ssh: 가상머신 접속 (vagrant ssh k8s-master)
   >
   > vagrant destroy: 가상머신 삭제

   

4. Worker Node 연결: Worker Node들을 Master에 연결하여 쿠버네티스 클러스터 구축

5. 설치 확인: Node와 Pod 상태 조회

6. 대시보드 접근: Host OS에서 웹 브라우저를 이용해 클러스터 Dashboard 접근



---

