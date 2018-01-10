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
