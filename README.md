# CurateND

This application will be deployed to [curate.nd.edu](http://curate.nd.edu).

It's primary function is to be a self-deposit interface for our institutional digital repository.

## Testing

First, you will need a running a specific instance of Fedora & SOLR - there are
XACML policy changes in Fedora related to soft-deletes. This can be done via the
following commands:

    rake curatend:jetty:start

Once jetty is started, run either of the following

`rake` or `rspec`

### Using Zeus

```shell
$ zeus start
```

And then:

```shell
$ zeus test path/to/spec.rb:LINENO
```

## Application Status

[![Build Status](https://travis-ci.org/ndlib/curate_nd.png)](https://travis-ci.org/ndlib/curate_nd)
