docker-tinynode
=============

A small [buildroot](http://buildroot.uclibc.org/)-based image for [Docker](http://docker.io/), with [NodeJS](http://nodejs.org/) installed. It clocks in around 30MB.

The following useful modules/frameworks are installed:

* [NodeJS](http://nodejs.org) version 0.10.30
* [Express](http://expressjs.com/) version 4.9.8
* [CoffeeScript](http://coffeescript.org/) version 1.8.0
* [Socket IO](http://socket.io/) version 1.1.0
* [Underscore.js](http://underscorejs.org/) version 1.7.0
* [forever](https://github.com/nodejitsu/forever) version 0.11.1

Currently using buildroot 2014.08

If you want to install different frameworks or specific versions, edit the
`tinynode_defconfig` file, specifically the `BR2_PACKAGE_NODEJS_MODULES_ADDITIONAL` parameter. Everything there just gets passed to npm as-is, so you can
specify things like `forever@0.11.1` if you want that specific version.

# What do I do with this?

It's pretty much up to you! I'm assuming you're already familiar with Docker --
if you aren't, I suggest you read up on the Docker documentation.
https://docs.docker.com/userguide/

Here's a few ideas/pointers.

## Bind-mount a volume with your script (easy)

So let's say your nodejs app is in a folder at `/data/myapp` - replace that with wherever 
your actual script is. And let's say your script is named `app.js`, and I'm going to assume 
your script is running something on port 8080.

You can mount the app's folder into the container with the `-v` parameter. You can place it 
anywhere you want, but the image is using `/home/default` as its working directory, so I 
recommend placing it somewhere in there.

The image's `ENTRYPOINT` parameter is `forever` - meaning when you start a container, anything 
you write out after the image name will be passed to `forever`. So at the minimum, you'll need 
the path to the script you want to run, but you can also pass options to `forever` - they're all 
listed in [forever's readme](https://github.com/nodejitsu/forever/blob/master/README.md)

The one action you do *not* want to pass to `forever` is `start` - that causes `forever` to fork 
and detach and run as a daemon. Docker expects programs to *not* do that, so the container will 
just immediately exit if you use `start`

So putting it all together, you can run a command line:

`docker run -p 8080:8080 -v /data/myapp:/home/default/myapp jprjr/tinynode myapp/app.js`

* The `-p 8080:8080` means to connect your host machine's port 8080 to the container port 8080.
* the `-v /data/myapp:/home/default/myapp` will mount `/data/myapp` (on your host) to `/home/default/myapp` (in the container)
* `jprjr/tinynode` is the name of the image
* `myapp/app.js` is the argument you're passing to `forever` - since the image's working directory is `/home/default` you can use a relative path.

If you need more ports, you can just add more `-p` arguments, nd if you need to mount more 
folders, just add more `-v` arguments, etc. You could replace `myapp/app.js` with `-w myapp/app.js` 
and forever will autoreload the script when the file changes.


## Build a new image from this one (less easy)

Just create a Dockerfile and begin with

```
FROM jprjr/tinynode
```

And do whatever you want. Your image will inherit a few things by default, like 
the `ENTRYPOINT`, `WORKDIR`, and `USER` parameters. Then in your Dockerfile, you can use 
commands like `ADD` to place your script into your new image, but then you'd have to
rebuild the image anytime you update/change your app. This is why I recommend mounting a volume
instead.

You can overwrite any of those parameters if you want, and you could add a `CMD` parameter 
if you want a default command to get passed to `forever`, etc.
