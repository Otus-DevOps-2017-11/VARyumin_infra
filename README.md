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

* Созданы 2 окружения:
 ```
 - stage
 - prod
 ```
* Параметризированны конфигурации модулей
* Конфигурационные файлы отформатированны

#### Задание со звездочкой:
* State перенесен в Google Cloud Storage
* Применить изменения с использованием:
```
terraform init -backend-config=backend.tfvars.example
```
#### Задание со звездочкой:
* Добавлен provisioner для деплоя приложения:
```
  provisioner "file" {
    content     = "${data.template_file.pumaservice.rendered}"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
```
* Добавлен provisioner для конфигурации базы данных:
```
  provisioner "file" {
    content     = "${data.template_file.mongod-config.rendered}"
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/mongod.conf /etc/mongod.conf",
      "sudo systemctl restart mongod",
    ]
  }
```

## Homework 10
* Созданы 4 инфентори файла:
```
- inventory :
```
```
[app]
appserver ansible_host=35.189.77.52

[db]
dbserver ansible_host=35.189.92.235
```
```
- inventory.yml :
```
```
app:
  hosts:
    appserver:
      ansible_host: 35.189.77.52

db:
  hosts:
    dbserver:
      ansible_host: 35.189.92.235
```
```
- inventory.json :
```
```
{
  "app": {
    "hosts": {
      "appserver": {
        "ansible_host": "35.189.77.52"
      }
    }
  },
  "db": {
    "hosts": {
      "dbserver": {
        "ansible_host": "35.189.92.235"
      }
    }
  }
}
```
Добавил файл для поддержки Ansible 2.0
```
- inventory_2.0.json :
```
```
{
    "appserver": {
        "hosts": ["35.189.77.52"]
    },
    "dbserver": {
        "hosts": ["35.189.92.23"]
    }
}
```
* Проверка inventory.json:

1.
```
ansible all -m command -a uptime -i inventory.json

dbserver | SUCCESS | rc=0 >>
 07:35:11 up 23:36,  1 user,  load average: 0.00, 0.00, 0.00

appserver | SUCCESS | rc=0 >>
 07:35:11 up 23:35,  1 user,  load average: 0.00, 0.00, 0.00

```

2.
```
ansible all -m command -a uptime -i inventory.json
appserver | SUCCESS | rc=0 >>
 07:35:40 up 23:36,  1 user,  load average: 0.00, 0.00, 0.00

dbserver | SUCCESS | rc=0 >>
 07:35:40 up 23:37,  1 user,  load average: 0.00, 0.00, 0.00
```

Я так понимаю что Ansible параллельно выполняет команду uptime на всех хостах а не последовательно по хосту.
Потому что в первом случаи мне первым вернулся результат с dbserver, а во втором случаи appserver

* Прочитана и разобрана статья из документации Ansible "Developing Dynamic Inventory Sources"

## Homework 11

* Создание ansible playbooks

* Были созданы ansible playbooks для развертывания приложения и настройки базы данных

* Так же был переделан провижининг в packer со скриптов на ansible

#### Задание со звездочкой

*Найдено два варианта dynamic inventory для GCP:*

```
 - gce.py(описан в документации ansible http://docs.ansible.com/ansible/latest/guide_gce.html)
 - terraform-inventory (https://github.com/adammck/terraform-inventory)
```
terraform-inventory у меет работать не только с GCP.
Для установки можно воспользоваться уже скомпилированными файлами или скомпилировать самим.
Для использования terraform-inventory нужно указать переменную окружения TF_STATE, в которой нужно прописать путь до папки с terraform или путь до tfstate файла. terraform-inventory умеет работать с remote state.

```bash
ansible-playbook --inventory-file=/path/to/terraform-inventory site.yml
```

## Homework 12

#### Структура директории ansible:
```
.
|-- ansible.cfg
|-- environments
|   |-- prod
|   |   |-- group_vars
|   |   |   |-- all
|   |   |   |-- app
|   |   |   `-- db
|   |   |-- inventory
|   |   `-- requirements.yml
|   `-- stage
|       |-- group_vars
|       |   |-- all
|       |   |-- app
|       |   `-- db
|       |-- inventory
|       `-- requirements.yml
|-- old
|   |-- files
|   |   `-- puma.service
|   |-- inventory.json
|   |-- inventory.yml
|   |-- inventory_2.0.json
|   `-- templates
|       |-- db_config.j2
|       `-- mongod.conf.j2
|-- playbooks
|   |-- app.yml
|   |-- db.yml
|   |-- deploy.yml
|   |-- packer_app.yml
|   |-- packer_db.yml
|   |-- reddit_app_multiple_plays.yml
|   |-- reddit_app_one_play.yml
|   `-- site.yml
`-- roles
    |-- app
    |   |-- README.md
    |   |-- defaults
    |   |   `-- main.yml
    |   |-- files
    |   |   `-- puma.service
    |   |-- handlers
    |   |   `-- main.yml
    |   |-- meta
    |   |   `-- main.yml
    |   |-- tasks
    |   |   `-- main.yml
    |   |-- templates
    |   |   `-- db_config.j2
    |   |-- tests
    |   |   |-- inventory
    |   |   `-- test.yml
    |   `-- vars
    |       `-- main.yml
    |-- db
    |   |-- README.md
    |   |-- defaults
    |   |   `-- main.yml
    |   |-- files
    |   |-- handlers
    |   |   `-- main.yml
    |   |-- meta
    |   |   `-- main.yml
    |   |-- tasks
    |   |   `-- main.yml
    |   |-- templates
    |   |   `-- mongod.conf.j2
    |   |-- tests
    |   |   |-- inventory
    |   |   `-- test.yml
    |   `-- vars
    |       `-- main.yml

```
#### Выполнена самостоятельная работа:
```
 - Добавьте в конфигурацию терраформа открытие 80 порта для инстанса приложения:
```

```
 resource "google_compute_firewall" "firewall_nginx" {
   name    = "default-allow-nginx"
   network = "default"

   allow {
     protocol = "tcp"
     ports    = ["80"]
   }

   source_ranges = "${var.source_ranges}"
 }
```

```
 - Добавьте вызов роли jdauphant.nginx в плейбук app.yml
```

```
- name: Configure App
  hosts: app
  become: true

  roles:
    - app
    - jdauphant.nginx
```

```
 - Примените плейбук site.yml для окружения stage и проверьте, что приложение теперь доступно на 80 порту:
```
<img src="http://snappyimages.nextwavesrl.netdna-cdn.com/img/3526981823aa06e2357f55665d7bdde0.png" width="500">

## Домашнаяя работа 13
* описали для Vagrant две виртуалки в Virtualbox
* Создали/запустили эти две виртуалки appsever и dbserver посредством vagrant up
* Проверили их доступность для хоста и друг для друга

```
[alfar@alfarPC ansible (ansible-4)]$ vagrant status
Current machine states:

dbserver                  running (virtualbox)
appserver                 running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
[alfar@alfarPC ansible (ansible-4)]$ vagrant ssh appserver
Welcome to Ubuntu 16.04.3 LTS (GNU/Linux 4.4.0-112-generic x86_64)
Last login: Sat Feb 10 14:43:14 2018 from 10.0.2.2
vagrant@appserver:~$ ping -c 2 10.10.10.10
PING 10.10.10.10 (10.10.10.10) 56(84) bytes of data.
64 bytes from 10.10.10.10: icmp_seq=1 ttl=64 time=0.385 ms
64 bytes from 10.10.10.10: icmp_seq=2 ttl=64 time=0.256 ms

--- 10.10.10.10 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1005ms
rtt min/avg/max/mdev = 0.256/0.320/0.385/0.066 ms
```

#### Доработка ролей. Провижининг.
* Добавили в Vagrantfile провижининг ansible для dbserver
* Добавили в ansible еще один playbook c raw task, который проверяет и устанавливает питон если необходимо.
* Доработали роль db, перенеся в неё установку и настройку mongod на основе плейбука packer_db.yml
* Применили доработанный провеижен на dbserver
* Проверили с appserver доступность mongod на dbserver
* Аналогично доработали роль app, добавили провижинингдля appserver, и применили.
* Однако ошибка - юзера нет в виртуалках
* Параметризовали юзера для выкладки как deploy_user. Дефолт - appuser, переопределено в Vagrantfile через extra_vars как ubuntu
* Применение `vagrant provision appserver` упал с ошибкой
* Зашел на сервер `vagrant ssh appserver` и выполнил команду `whoami` результат `vagrant` поменял extra_vars на vagrant
* Проверили доступность приложения по адресу 10.10.10.20:9292 - работает
* Выполнил задание со зведочкой по nginx
```
nginx_sites:
  default:
    - listen 80 default_server
    - server_name _
    - root "{{ nginx_sites_default_root }}"
    - location / {proxy_pass http://ruby;}
nginx_configs:
  upstream:
      - upstream ruby { server 127.0.0.1:9292 weight=10; }
```
* Уничтожили всё `vagrant destroy -f` и прересоздали заново `vagrant up`
* Вновь проверили доступность приложения по адресу 10.10.10.20 - работает. Вновь уничтожили всё.
#### Тестирование роли
* Установили в виртуалэнв molecule и зависимости
* Создали заготовку тестов для роли db в папке `ansible/roles/db`: `molecule init scenario --scenario-name default -r db -d vagrant`
* добавили проверки сервиса монго:  запущен, включен, есть конфиг, в конфиге настроено на прослушивание на всех интерфейсах (0.0.0.0)
* Создали виртуалку средствами molecule (но она по сути пустая, без применного ансибла)
* Поправили плейбук который сгенерен molecule (выполнение из под судо (become), переменная mongo_bind_ip)
* Применили плейбук, созданный molecule `molecule converge`
* Прогнали тесты `molecule verify`
* (разобрали виртуалки через `molecule destroy`)
#### Самостоятельное задание
* Добавили проверку что БД слушает по порту 27017
```
#Check if MongoDB is listening on 27017
def test_mongo_running_and_enabled(host):
    port = host.socket("tcp://27017")
    assert port.is_listening
```
* Заменили в плейбуках packer_db и packer_app таски на роли db и app
* Пофиксили пути к плейбукам в шаблонах packer: app.json и db.json
