## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).
```последняя 1.6 - не удалось использовать бакет в яндексе, остановился на 1.3.10```

Предварительная подготовка к установке и запуску Kubernetes кластера.

[+] 1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя  
```Сервисный аккаунт с правами Editor```

[+]2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   <strike>а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/) </strike> 

   б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте

   ```сделал S3 бакет т.к. без VPN не дает зайти в Terraform Cloud```
   
   ![image](https://github.com/askarpoff/devops-diplom/assets/108946489/72d656ba-fa17-4367-bfce-d1bd6d4bdb6a)


[+]3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)  
  <strike> а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  </strike>
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/45ff8ce8-8561-48e7-be86-1f0183c67c56)

4. Создайте VPC с подсетями в разных зонах доступности.

```Делал через Yandex Managed Service for Kubernetes``` 

5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.

```В следующем пункте создан Kubernetes кластер через терраформ``` 

6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

<strike>1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.</strike>
[+] 2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

[+]1. Работоспособный Kubernetes кластер.

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/91544af9-5dad-4f7d-9bb9-7cda921491e3)

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/29ea6cb9-0254-4f8e-be05-d6aca6468726)


[+]2. В файле `~/.kube/config` находятся данные для доступа к кластеру.

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/a9e79264-2592-4e2e-890f-70614929d698)

[+]3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/1061f005-3137-4107-91eb-87a1524035dc)


---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

[+]1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
<strike>2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.</strike>

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/0008cafa-e07d-435b-a73a-83b705c48440)
```Репозиторий поднят на собственных мощностях https://git.askarpoff.site/, ни gitlab.com, ни Managed Gitlab меня не устроили.```

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/db3d4d74-fde4-4418-91d7-c1aba41d5096)
```очень примитивный докерфайл с сайтом-лендингом```
   
2. Регистр с собранным docker image. В качестве регистра может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.
```В качестве регистра использовал Dockerhub, вроде не принципиально```

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/b50921b9-4d61-4b6d-b17c-bdb7fe73f068)

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемый способ выполнения:
[+]1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
<strike>2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.</strike>

Альтернативный вариант:
[+]1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)

В скрипте:
Устанавливаю gitlab-runner от своего Gitlab
```bash
helm install --namespace gitlab gitlab-runner gitlab/gitlab-runner \
  --set rbac.create=true \
  --set gitlabUrl=https://git.askarpoff.site/ \
  --set runnerRegistrationToken=$(cat runnertoken) \
  -f ./gitlab/config.toml
```
![image](https://github.com/askarpoff/devops-diplom/assets/108946489/90dbf240-fbfe-4490-9053-3f736707b19f)

Устанавливаю ingress-контроллер
```helm install --namespace stage ingress-nginx ingress-nginx/ingress-nginx```

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
В gitlab файл <b>k8s.yaml</b>
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapp
  namespace: stage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: simpleapp
  template:
    metadata:
      namespace: simpleapp
      labels:
        app: simpleapp
    spec:
      containers:
        - name: simpleapp
          image: __VERSION__
          imagePullPolicy: Always
          ports:
            - containerPort: 80
      imagePullSecrets:
        - name: regcred
```
<b>.gitlab-ci.yml</b>
```
docker-build:
  image: docker:cli
  stage: build
  services:
    - docker:dind
  variables:
    DOCKER_IMAGE_NAME: $CI_REGISTRY_IMAGE:latest
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
  script:
    - docker build  -t "$DOCKER_IMAGE_NAME" .
    - docker push "$DOCKER_IMAGE_NAME"
  rules:
    - if: $CI_COMMIT_BRANCH
      exists:
        - Dockerfile
docker-build-tag:
  only: [tags]
  image: docker:cli
  stage: build
  services:
    - docker:dind
  variables:
    DOCKER_IMAGE_NAME: $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
  script:
    - docker build  -t "$DOCKER_IMAGE_NAME" .
    - docker push "$DOCKER_IMAGE_NAME"
deploy:
  only: [tags]
  image: gcr.io/cloud-builders/kubectl:latest
  stage: deploy
  variables:
    DOCKER_IMAGE_NAME: $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
  script:
    - kubectl config set-cluster "diplomregionalcluster" --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin-user --token="$KUBE_TOKEN"
    - kubectl config set-context stage --cluster="diplomregionalcluster" --user=admin-user
    - kubectl config use-context stage
    - sed -i "s,__VERSION__,"$DOCKER_IMAGE_NAME"," k8s.yaml
    - kubectl apply -f k8s.yaml
```
В настройках CI/CD установлены переменные для доступа к регистру и к кластеру k8s

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/57c731a9-f2f1-4551-a829-37ddd6165eb6)

3. Http доступ к web интерфейсу grafana.
![image](https://github.com/askarpoff/devops-diplom/assets/108946489/7586f00e-62c6-43fa-a45c-ac5352101fef)

Доступ к Graphana предоставлен через LoadBalancer, 3000 порт.
Через Ingress не получилось, т.к. срабатывает перенаправление на /login

4. Дашборды в grafana отображающие состояние Kubernetes кластера.

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/2e9c042b-90e3-42d2-ac82-f4c91fa4b6ac)

![image](https://github.com/askarpoff/devops-diplom/assets/108946489/b610f365-b85d-4a50-b6e2-6da1810e1588)

5. Http доступ к тестовому приложению.
Доступ к тестовому приложению организован через Ingress
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  namespace: stage
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
            service:
              name: simpleapp
              port:
                number: 80
```
IP для доступа виден в External IP
![image](https://github.com/askarpoff/devops-diplom/assets/108946489/19260978-f54a-425e-9f10-8c3d66d1d1f6)

По этому IP открывается сайт-лендинг(тестовое приложение)
![image](https://github.com/askarpoff/devops-diplom/assets/108946489/964160e4-9bbd-4fa5-bfec-093ef49bd25b)

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
   
Все реализовано через <b>.gitlab-ci.yml</b>
```
docker-build:
  image: docker:cli
  stage: build
  services:
    - docker:dind
  variables:
    DOCKER_IMAGE_NAME: $CI_REGISTRY_IMAGE:latest
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
  script:
    - docker build  -t "$DOCKER_IMAGE_NAME" .
    - docker push "$DOCKER_IMAGE_NAME"
  rules:
    - if: $CI_COMMIT_BRANCH
      exists:
        - Dockerfile
docker-build-tag:
  only: [tags]
  image: docker:cli
  stage: build
  services:
    - docker:dind
  variables:
    DOCKER_IMAGE_NAME: $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
  script:
    - docker build  -t "$DOCKER_IMAGE_NAME" .
    - docker push "$DOCKER_IMAGE_NAME"
deploy:
  only: [tags]
  image: gcr.io/cloud-builders/kubectl:latest
  stage: deploy
  variables:
    DOCKER_IMAGE_NAME: $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
  script:
    - kubectl config set-cluster "diplomregionalcluster" --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin-user --token="$KUBE_TOKEN"
    - kubectl config set-context stage --cluster="diplomregionalcluster" --user=admin-user
    - kubectl config use-context stage
    - sed -i "s,__VERSION__,"$DOCKER_IMAGE_NAME"," k8s.yaml
    - kubectl apply -f k8s.yaml
```
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
Исправим кнопку
 ![image](https://github.com/askarpoff/devops-diplom/assets/108946489/4e8a80af-6195-42f4-9f26-b3566cb21085)

Происходит сборка контейнера
![image](https://github.com/askarpoff/devops-diplom/assets/108946489/4764968a-c7a0-4ad4-9f48-b14f5f4aa414)
<details>
 <summary>job log</summary>
```
Running with gitlab-runner 16.5.0 (853330f9)
  on gitlab-runner-6fb47fc555-txvqh ATTpUCtB, system ID: r_fstbTxSKKsdC
Preparing the "kubernetes" executor
00:00
Using Kubernetes namespace: gitlab
Using Kubernetes executor with image docker:cli ...
Using attach strategy to execute scripts...
Preparing environment
00:27
Using FF_USE_POD_ACTIVE_DEADLINE_SECONDS, the Pod activeDeadlineSeconds will be set to the job timeout: 1h0m0s...
Waiting for pod gitlab/runner-attpuctb-project-1-concurrent-0-6vwr975n to be running, status is Pending
Waiting for pod gitlab/runner-attpuctb-project-1-concurrent-0-6vwr975n to be running, status is Pending
	ContainersNotInitialized: "containers with incomplete status: [init-permissions]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
Waiting for pod gitlab/runner-attpuctb-project-1-concurrent-0-6vwr975n to be running, status is Pending
	ContainersNotInitialized: "containers with incomplete status: [init-permissions]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
Waiting for pod gitlab/runner-attpuctb-project-1-concurrent-0-6vwr975n to be running, status is Pending
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
Waiting for pod gitlab/runner-attpuctb-project-1-concurrent-0-6vwr975n to be running, status is Pending
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
Waiting for pod gitlab/runner-attpuctb-project-1-concurrent-0-6vwr975n to be running, status is Pending
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
Waiting for pod gitlab/runner-attpuctb-project-1-concurrent-0-6vwr975n to be running, status is Pending
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
Waiting for pod gitlab/runner-attpuctb-project-1-concurrent-0-6vwr975n to be running, status is Pending
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
Running on runner-attpuctb-project-1-concurrent-0-6vwr975n via gitlab-runner-6fb47fc555-txvqh...
Getting source from Git repository
00:02
Fetching changes with git depth set to 20...
Initialized empty Git repository in /builds/root/simple_landing/.git/
Created fresh repository.
Checking out 63c1c9aa as detached HEAD (ref is main)...
Skipping Git submodules setup
Executing "step_script" stage of the job script
00:24
$ docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store
Login Succeeded
$ docker build  -t "$DOCKER_IMAGE_NAME" .
#0 building with "default" instance using docker driver
#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 79B done
#1 DONE 0.1s
#2 [internal] load .dockerignore
#2 transferring context: 2B done
#2 DONE 0.1s
#3 [internal] load metadata for docker.io/library/nginx:latest
#3 ...
#4 [auth] library/nginx:pull token for registry-1.docker.io
#4 DONE 0.0s
#3 [internal] load metadata for docker.io/library/nginx:latest
#3 DONE 2.1s
#5 [1/2] FROM docker.io/library/nginx@sha256:86e53c4c16a6a276b204b0fd3a8143d86547c967dc8258b3d47c3a21bb68d3c6
#5 resolve docker.io/library/nginx@sha256:86e53c4c16a6a276b204b0fd3a8143d86547c967dc8258b3d47c3a21bb68d3c6
#5 resolve docker.io/library/nginx@sha256:86e53c4c16a6a276b204b0fd3a8143d86547c967dc8258b3d47c3a21bb68d3c6 0.1s done
#5 ...
#6 [internal] load build context
#6 transferring context: 12.38MB 0.2s done
#6 DONE 0.3s
#5 [1/2] FROM docker.io/library/nginx@sha256:86e53c4c16a6a276b204b0fd3a8143d86547c967dc8258b3d47c3a21bb68d3c6
#5 sha256:86e53c4c16a6a276b204b0fd3a8143d86547c967dc8258b3d47c3a21bb68d3c6 1.86kB / 1.86kB done
#5 sha256:c20060033e06f882b0fbe2db7d974d72e0887a3be5e554efdb0dcf8d53512647 8.15kB / 8.15kB done
#5 sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780 0B / 41.38MB 0.2s
#5 sha256:85c41ebe6d660b75d8e2e985314ebce75e602330cd325bc5cfbf9d9723c329a1 0B / 627B 0.2s
#5 sha256:d2e65182b5fd330470eca9b8e23e8a1a0d87cc9b820eb1fb3f034bf8248d37ee 1.78kB / 1.78kB done
#5 sha256:578acb154839e9d0034432e8f53756d6f53ba62cf8c7ea5218a2476bf5b58fc9 0B / 29.15MB 0.2s
#5 sha256:578acb154839e9d0034432e8f53756d6f53ba62cf8c7ea5218a2476bf5b58fc9 5.24MB / 29.15MB 0.3s
#5 sha256:85c41ebe6d660b75d8e2e985314ebce75e602330cd325bc5cfbf9d9723c329a1 627B / 627B 0.4s done
#5 sha256:578acb154839e9d0034432e8f53756d6f53ba62cf8c7ea5218a2476bf5b58fc9 11.53MB / 29.15MB 0.4s
#5 sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780 3.15MB / 41.38MB 0.5s
#5 sha256:578acb154839e9d0034432e8f53756d6f53ba62cf8c7ea5218a2476bf5b58fc9 19.92MB / 29.15MB 0.5s
#5 sha256:7170a263b582e6a7b5f650b7f1c146267f694961f837ffefc2505bb9148dd4b0 0B / 958B 0.5s
#5 sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780 15.73MB / 41.38MB 0.7s
#5 sha256:578acb154839e9d0034432e8f53756d6f53ba62cf8c7ea5218a2476bf5b58fc9 26.21MB / 29.15MB 0.7s
#5 sha256:7170a263b582e6a7b5f650b7f1c146267f694961f837ffefc2505bb9148dd4b0 958B / 958B 0.7s
#5 sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780 20.97MB / 41.38MB 0.8s
#5 sha256:578acb154839e9d0034432e8f53756d6f53ba62cf8c7ea5218a2476bf5b58fc9 29.15MB / 29.15MB 0.8s
#5 sha256:7170a263b582e6a7b5f650b7f1c146267f694961f837ffefc2505bb9148dd4b0 958B / 958B 0.7s done
#5 sha256:8f28d06e2e2ec58753e1acf21d96619aafeab87e63e06fb0590f56091db38014 0B / 367B 0.8s
#5 sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780 26.21MB / 41.38MB 1.0s
#5 sha256:578acb154839e9d0034432e8f53756d6f53ba62cf8c7ea5218a2476bf5b58fc9 29.15MB / 29.15MB 0.9s done
#5 sha256:8f28d06e2e2ec58753e1acf21d96619aafeab87e63e06fb0590f56091db38014 367B / 367B 1.0s done
#5 sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780 28.49MB / 41.38MB 1.1s
#5 extracting sha256:578acb154839e9d0034432e8f53756d6f53ba62cf8c7ea5218a2476bf5b58fc9
#5 sha256:c1dfc7e1671e8340003503af03d067bae6846c12c30cbc1af3e589cb124fd45d 0B / 1.40kB 1.1s
#5 sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780 35.65MB / 41.38MB 1.2s
#5 sha256:6f837de2f88742f4e8083bff54bd1c64c1df04e6679c343d1a1c9a650078fd48 0B / 1.21kB 1.2s
#5 sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780 39.85MB / 41.38MB 1.3s
#5 sha256:c1dfc7e1671e8340003503af03d067bae6846c12c30cbc1af3e589cb124fd45d 1.40kB / 1.40kB 1.2s done
#5 sha256:6f837de2f88742f4e8083bff54bd1c64c1df04e6679c343d1a1c9a650078fd48 1.21kB / 1.21kB 1.3s done
#5 sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780 41.38MB / 41.38MB 2.2s done
#5 extracting sha256:578acb154839e9d0034432e8f53756d6f53ba62cf8c7ea5218a2476bf5b58fc9 1.7s done
#5 extracting sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780
#5 extracting sha256:e398db710407fbc310b4bc0b0db1c94161480ac9b44638c6655939f426529780 1.3s done
#5 extracting sha256:85c41ebe6d660b75d8e2e985314ebce75e602330cd325bc5cfbf9d9723c329a1
#5 extracting sha256:85c41ebe6d660b75d8e2e985314ebce75e602330cd325bc5cfbf9d9723c329a1 done
#5 extracting sha256:7170a263b582e6a7b5f650b7f1c146267f694961f837ffefc2505bb9148dd4b0 done
#5 extracting sha256:8f28d06e2e2ec58753e1acf21d96619aafeab87e63e06fb0590f56091db38014 done
#5 extracting sha256:6f837de2f88742f4e8083bff54bd1c64c1df04e6679c343d1a1c9a650078fd48
#5 extracting sha256:6f837de2f88742f4e8083bff54bd1c64c1df04e6679c343d1a1c9a650078fd48 done
#5 extracting sha256:c1dfc7e1671e8340003503af03d067bae6846c12c30cbc1af3e589cb124fd45d done
#5 DONE 6.0s
#7 [2/2] COPY src /usr/share/nginx/html
#7 DONE 2.0s
#8 exporting to image
#8 exporting layers
#8 exporting layers 0.1s done
#8 writing image sha256:e1805a3bb577ce773d3f08d7d1b04b50792da76b56300ce46a1c735945231848 done
#8 naming to docker.io/askarpoff/simple_landing:latest done
#8 DONE 0.1s
WARNING: buildx: git was not found in the system. Current commit information was not captured by the build
$ docker push "$DOCKER_IMAGE_NAME"
The push refers to repository [docker.io/askarpoff/simple_landing]
cac1cbe5953d: Preparing
505f49f13fbe: Preparing
9920f1ebf52b: Preparing
768e28a222fd: Preparing
715b32fa0f12: Preparing
e503754c9a26: Preparing
609f2a18d224: Preparing
ec983b166360: Preparing
e503754c9a26: Waiting
609f2a18d224: Waiting
ec983b166360: Waiting
768e28a222fd: Layer already exists
9920f1ebf52b: Layer already exists
505f49f13fbe: Layer already exists
715b32fa0f12: Layer already exists
e503754c9a26: Layer already exists
609f2a18d224: Layer already exists
ec983b166360: Layer already exists
cac1cbe5953d: Pushed
latest: digest: sha256:a6011dc1f416548bd31e99c96da709631e579553ac840097c133cd81642d5730 size: 1990
Cleaning up project directory and file based variables
00:00
Job succeeded
```
</details>
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
