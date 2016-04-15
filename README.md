[![Stories in Ready](https://badge.waffle.io/ndlib/curate_nd.png?label=ready&title=Ready)](https://waffle.io/ndlib/curate_nd)
# CurateND
[![Build Status](https://travis-ci.org/ndlib/curate_nd.png)](https://travis-ci.org/ndlib/curate_nd)

This application will be deployed to [curate.nd.edu](http://curate.nd.edu).

It's primary function is to be a self-deposit interface for our institutional digital repository.

## Installation Notes

Installing the clamav gem on OS X is a trying process. It can be safely excluded
from your development environment 

```console
$ bundle install --without headless
```

## Testing

First, you will need a running a specific instance of Fedora & SOLR - there are
XACML policy changes in Fedora related to soft-deletes. This can be done via the
following commands:

    rake curatend:jetty:start

Once jetty is started, run either of the following

`rake` or `rspec`

## Running the application under SSL

```console
$ bundle exec thin start -p 3000 --ssl --ssl-key-file dev_server_keys/server.key --ssl-cert-file dev_server_keys/server.crt
```
