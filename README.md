
Debian, PostgreSQL 9.5
================================


__To build execute:__
```
docker build -t postgresql:9.5 .
```


__Lauching a container from your new image:__
```
docker run -d -P --name postgresql95 postgresql:9.5
```


__Binding to a specific port:__
```
docker run -d -p 5433:5432 --name postgresql95 postgresql:9.5
```


__Bind mount a volume:__
```
docker run -d -v /home/user/workspace/scripts/:/ postgresql:9.5
```


__Access a shell after run container:__
```
docker exec -it [ CONTAINER ID ] bash
```

-------


#### CHANGELOG

[Link](https://github.com/luk4z7/docker-build-postgresql/blob/master/CHANGELOG.md)
