## Blue-Green Deployment Strategy
> with Traefik & Docker Compose

Docker Compose, Traefik 사용 중인 서비스에 무중단 배포를 구현

### 목적

- 쿠버네티스 혹은 도커스웜을 사용하기에는 작은 규모의 프로젝트라고 판단
- 기존 기술스택인 Docker Compose와 Traefik을 이용하여 최소한의 비용으로 Blue-Green 배포 전략을 구현할 수 있는지 확인 

### 목표

- 도커 환경에서 무중단 배포를 구현
- 쿠버네티스, 도커 스웜등과 같은 컨테이너 오케스트레이션 도구를 사용하지 않는 무중단 배포을 구현

### 개발환경

- 테스트 API: Golang 1.24
  - no framework, net/http 사용
  - 단순 health check endpoint만 구현.

- Treafik-Proxy: 로드 밸런서 역할
  - 도커 친화적이며, 로드 밸런서 기능과 리버스 프록시 기능등이 존재함
  - 단일 서버에서 여러 개의 컨테이너를 관리 가능하기에 현재 목적에 적합하다고 판단

- Utility & ETC: GNU Make, bash shell script
  - CI/CD를 위해서 자동화 가능하게 쉘 스크립트로 복잡한 로직을 구현
  - make의 경우, script들을 커맨드화 하기 위해 사용

### Traefik Config
> [config](./config)

- static.yml: traefik 기본 설정
- dynamic.yml: test api 라우팅 및 로드밸런서 설정 

### Scripts

- deploy.sh: docker compose 명령 구동을 위한 스크립트
- switch-container.sh: blue, green swithcing을 위한 스크립트

### Docker Compose 구성

```shell
- docker-compose.yml: traefik 구동을 위한 메인 docker copmose 파일
- docker-compose.blue.yml: api-blue 구동을 위한 docker compose 파일
- docker-compose.green.yml: api-green 구동을 위한 docker compose 파일
```

### 시험 방법

```shell
# 도커 external network 생성
$ docker network create shared_network

# build api server image
$ make build-docker

# Blue-Green Deploy
$ make deploy

# 정말 중단되지 않는지 학인 하기 위한 간단한 프로그램
$ go run test/main.go
```

### 결론

> 도커 환경에서 무중단 배포에 성공 했는가?

- 서비스가 일반 사용자가 사용하는 서버인 경우 성공일 수 있음.
- 실시간 서비스인 경우라면 실패 

#### 문제점 및 개선해야할 점
- traefik, docker의 health check의 경우 interval이 초 단위이기 때문에 최소 1초는 중단되는 것.
- 현재 프로젝트의 문제는 heal check를 1초로 했을 경우의 서버 부하를 측정하지 않았음.
- 무중단의 기준은 어느정도인가? 정말 완벽한 Zero Down이 가능한가?
