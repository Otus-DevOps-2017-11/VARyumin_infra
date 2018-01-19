# VARyumin_infra

## Настройка сквозного подключения к удаленному хосту через Bastion

* Открыть ~/.ssh/config
* Добавить содрежимое:
```
##########  OTUS  ##########
Host bastion
	HostName 104.199.6.214
	Port 22
	User appuser
	IdentityFile ~/.ssh/appuser

Host someinternalhost
	ProxyCommand ssh -q bastion nc -q0 10.132.0.3 22

##########  OTUS  ##########
```
* Подключение к удаленному хост, не имеющего внешний ip адрес(someinternalhost)
```
alias someinternalhost='ssh appuser@someinternalhost'
someinternalhost
```

### Конфигурация подключения
* Хост bastion, IP: 104.199.6.214, внутр. IP: 10.132.0.2
* Хост: someinternalhost, внутр. IP: 10.132.0.3

## Homework 06
------

### 1. Самостоятельная работа
Созданы скрипты:
  * install_ruby.sh
  * install_mongodb.sh
  * deploy.sh

### 2. Дополнительное задание №1.
Создан startup_script.sh. За основу взяты выше описанные скрипты.  
Для того чтобы запустить инстанс с этим скриптом, использовались несколько методов:  
  * Передать скрипт локально в команду создания инстанса:
  ```
  gcloud compute instances create reddit-app  \
  --boot-disk-size=10GB   \
  --image-family ubuntu-1604-lts  \
  --image-project=ubuntu-os-cloud   
  --machine-type=g1-small \   
  --tags puma-server   \
  --restart-on-failure \
  --metadata-from-file startup-script=./startup_script.sh
  ```
  * Использовать скрипт через URL, например:  
  Создаем _bucket_:  
  `gsutil mb gs://varyumin-infra/`  
  Загружаем скрипт:  
  `gsutil cp ./startup_script.sh gs://varyumin-infra`  
  Проверяем:
  ```
  gsutil ls gs://varyumin-infra
  gs://varyumin-infra/startup_script.sh
  ```
  Команда создания инстанса с последющим использованием скрипта через URL:
  ```
  gcloud compute instances create reddit-app  \
  --boot-disk-size=10GB   \
  --image-family ubuntu-1604-lts  \
  --image-project=ubuntu-os-cloud   
  --machine-type=g1-small \   
  --tags puma-server   \
  --restart-on-failure \
  --metadata startup-script-url=gs://varyumin-infra/startup_script.sh
  ```

### 3. Дополнительное задание №2.

* Удаление правила fw через gcloud:  
`gcloud compute firewall-rules delete default-puma-server`

* Создание праивала fw через gcloud:
```
gcloud compute firewall-rules create default-puma-server \
--direction=INGRESS \
--description=default-puma-server \
--allow=TCP:9292  \
--network=default \
--target-tags puma-server \
--priority=1000

```
## Homework 7
#### Создание image HashiCorp Packer
```
packer build \
-var-file=variables.json \
immutable.json
```
#### Дальше воспользоваться gcloud
Use [Google Cloud Platform](https://cloud.google.com/)
```
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family reddit-full \
  --machine-type=f1-micro \
  --tags puma-server \
  --restart-on-failure \
  --zone=europe-west1-d
```
### Или одним скриптом
```
config-scripts/homework-07.sh
```

## Homework 8
#### Самостятельное задание выполнено:
1. Определил input переменную *private_key_path* для приватного ключа.
   Файл: variables.tf
   ```terraform
   variable private_key_path {
      description = "Path to the private key used for ssh access"
   }
   ```
   Файл: terraform.tfvars Но так как он не публикуется. То пример заполнения можно увидеть в файле: terraform.tfvars.example
   ```terraform
   private_key_path = "~/.ssh/appuser"
   ```
2. Определил input переменную *zone* для задания зоны в ресурсе "google_compute_instance" "app".
   Файл: variables.tf
   ```terraform
   variable zone {
     description = "Zone"
     default     = "europe-west1-b"
   }
   ```
   Значение в файле: terraform.tfvars не задано, в проекте используется значение по умолчанию.
3. Произведено форматирвоание с помощью команды **terrafrom frm** Terraform самостоятельно ищет файл с расширением .tf и производит форматирование в каждом файле.
4. Создан файл terraform.tfvars.example для примера заполнения файла terraform.tfvars с реальными данными.

#### Задание со звездочкой:
```
Если какой-то ключ добавлен "руками", без участия Terraform, то Terraform о нем ничего не знает и просто затирает этот ключ.
```
Текущий main.tf уже настроен на поднятие 2-х инстансов и настройки балансировки с пробросов порта с 80 на 9292.
По текущей схемы:
![LB Google](https://forward2.herokuapp.com/cloud/solutions/images/ilb-haproxy-network-lb-diagram.png?hl=en-GB)

## Homework 9

<img src="src/tree_terraform " width="500">
