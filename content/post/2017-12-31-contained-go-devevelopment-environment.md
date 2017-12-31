---
description: "A Self Contained golang development environment using Docker, vim and vim-go"
date: 2017-12-31T15:18:16+07:00
tags: [golang, development,	vim-go, docker]
categories: [development, programming, productivity]
series: []
keywords: [golang, development, container, contained, docker, vim-go]
socialsharing: true
title: "A Self Contained Go Development Environment"
totop: true
---
[Go(lang)][golang] is getting momentum in Indonesia during the recent years as big
names are migrating to Go. [Tokopedia][tokopedia-golang], [Go-Jek][gojek-golang], I'm looking
at you both. Not to mention many other startups build their tech-stack using Go
from the get-go due to the hype.

Go is an interesting programming language, not to mention it has fun part in it.
It combines the ease of dynamically typed language and the efficiency of statically
typed language with support for networked and multicore computing ([Go FAQ page][go-faq], 2017).
Moreover, we can also use [some functional programming techniques in Go][go-composition], fun, Right!

However, there was one thing that bothering me when I started to learn Go. It requires me to
set up all projects inside its `/go/src` directory which is a bit inconvenient for me as
I need to reorganize my directories' structure to do so. I put all my programming projects
under `Codes` directory, and I wanted it be the same even when coding Go program.

Then, an idea to use Docker to create a development environment for Go development popped up.
I have used Docker as a development tool to build and run a JavaScript application so I thought
it should be possible to create a development environment for Go.

The requirement was simple: I should not need to install anything to program with Go except for
downloading the Docker image. Then, the challenges came. Firstly, the editor should be embedded
in the Docker image as all go tools are inside the container it self. This is solved by
using the awesome Fatih's [vim-go][vim-go] that provided essential tools to write, build and test
Go programs. Secondly, as the development image would use vim as the editor, the vimrc should use
my [vimrc][nauval-vimrc] to avoid drop of productivity. This was resolved by creating `vimrc` to
container's `/etc/vim/` that will be load when starting up.

Thirdly, is to make sure that the project's
files are owned by the developer's machine user. To solve this, I leveraged the use anonymous `nobody`
user in the container by providing `-u uid:gid` (user id:group id) option. By doing so, the owner of
the edited files will be the same as the given `uid` and `guid`. Otherwise, the code will be owned
by `root` because it is the default user of the container.

After experimenting (and quite long hiatus) I developed `godev`, a self contained Go development environment.
As usual, the project is hosted in [github][godev-github] while the resulting image can be found in [docker hub][godev-docker-hub].

To try the container, run the following command:

```
$ docker run -it -v ${PWD}:/go/src/app  -u `id -u`:`id -g` npatmaja/godev sh -l
```

[golang]: https://golang.org/
[tokopedia-golang]: https://www.slideshare.net/qasim/golang-tokopedia-53090669
[gojek-golang]: https://www.techinasia.com/gojek-insider-account-of-scaling-900x-doubling
[go-faq]: https://golang.org/doc/faq#creating_a_new_language
[go-composition]: /2016/04/15/function-composition-in-go/
[vim-go]: https://github.com/fatih/vim-go
[nauval-vimrc]: https://github.com/npatmaja/dotfiles/blob/master/.vimrc
[godev-github]: https://github.com/npatmaja/go-dev-env/
[godev-docker-hub]: https://hub.docker.com/r/npatmaja/godev/
