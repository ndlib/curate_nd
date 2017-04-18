[![Stories in Ready](https://badge.waffle.io/ndlib/curate_nd.png?label=ready&title=Ready)](https://waffle.io/ndlib/curate_nd)
# CurateND
[![Build Status](https://travis-ci.org/ndlib/curate_nd.svg?branch=master)](https://travis-ci.org/ndlib/curate_nd)
[![Stories in Ready](https://badge.waffle.io/ndlib/curate_nd.png?label=ready&title=Ready)](https://waffle.io/ndlib/curate_nd)

This application will be deployed to [curate.nd.edu](http://curate.nd.edu).

Its primary function is to be a self-deposit interface for our institutional digital repository.

## Installation Notes

Installing the clamav gem on OS X is a trying process. It can be safely excluded
from your development environment

```console
$ bundle install --without headless
```

## Testing

You can run `bundle exec rake` to execute the test suite.

You can also boot up jetty (e.g. `bundle exec rake curatend:jetty:start`) and run individual specs via `bundle exec rspec spec/path/to/file_spec.rb`

## Running the application

Using non-SSL:

```console
$ bundle exec rails server
```

Using SSL:

```console
$ bundle exec thin start -p 3000 --ssl --ssl-key-file dev_server_keys/server.key --ssl-cert-file dev_server_keys/server.crt
```
