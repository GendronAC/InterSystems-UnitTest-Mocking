## mocking framework

Helps to run unittests with mocking objects

## prerequisits
The app works in IRIS For Health Enterprise and Community Edition
Namespace need to have Interoperability enabled

## Installation 

Clone/git pull the repo into any local directory

```
$ git clone git@github.com:GendronAC/InterSystems-UnitTest-Mocking.git
```

Open the terminal in this directory and run:

```
$ docker-compose up -d --build
```

Open then IRIS terminal with:

```
$ docker-compose exec iris iris session iris
USER>zn "IRISAPP"
IRISAPP>
```
Open control panel on http://localhost:40001/csp/sys/UtilHome.csp


## Install with ZPM

USER>zpm
zpm:USER>install mocking-framework

## How to use it