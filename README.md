# Heroku Packages Cedar 14

This repository provides the build scripts for packages that can be used in conjunction with the [heroku modular buildpack](https://github.com/JorgenEvens/heroku-modular-buildpack) on Heroku's cedar14 stack.

Rather than provide binaries as I did [for the cedar stack](https://github.com/JorgenEvens/heroku-packages), this repository provides the build scripts that can be used to build a repository from scratch.

This is more transparent and a more suitable upgrade path for future Heroku stack upgrades.

## How to build

The packages are built using docker and the `heroku/cedar` image provided by Heroku. In order to build your own version of this repository you will need a working `docker` commandline. The quickest way to get started is the [Docker Toolbox](https://www.docker.com/toolbox).

```
# Build all the packages, dist folder and repository index
cd /path/to/repository
make
```

## Download

If you are interested in a download of a pre-built repository, please leave me a message and I will provide a download link or running repository.