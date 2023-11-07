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

4. Дашборды в grafana отображающие состояние Kubernetes кластера.

5. Http доступ к тестовому приложению.

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
