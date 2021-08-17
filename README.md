# CurateND
[![Build Status](https://travis-ci.org/ndlib/curate_nd.svg?branch=master)](https://travis-ci.org/ndlib/curate_nd)
[![Stories in Ready](https://badge.waffle.io/ndlib/curate_nd.png?label=ready&title=Ready)](https://waffle.io/ndlib/curate_nd)

This application will be deployed to [curate.nd.edu](http://curate.nd.edu).

Its primary function is to be a self-deposit interface for our institutional digital repository.

Note: If using Docker, see [README_DOCKER.md](./README_DOCKER.md) for instructions.

## Installation Notes
Installing the clamav gem on OS X is a trying process. It can be safely excluded
from your development environment

```console
bundle install --without headless
```

## Testing

### 1. Start dependencies
```console
bundle exec rake curatend:jetty:start
```
<!-- ### 1.a Skipping MySQL password

You may consider adding `export SKIP_MYSQL_PASSWORD_FOR_LOCAL_DEVELOPMENT="true"` (or adding this to your `.bashrc` or `.profile`).  That export will tell the Rails configuration to skip using a password for the `config/database.yml` user in the local environment. -->

### 2. Run specs
To execute the full test suite, run
```console
bundle exec rake
```
To run individual specs, run

```console
bundle exec rspec spec/path/to/file_spec.rb
```

### Testing of Specific Curation Concern Types

The deposit page shows only the curation concern types that you are authorized to create. These options are generated from /config/work_type_policy_rules.yml.

Certain curation concern types are never created interactively:
* ETDs are now created only via Sipity. (However, they can be authorized through the work_type_policy_rules for local testing.)
* OSF Archives are imported via an option on the deposit menu.


## Running the application

### 1. Start dependencies
Before you start the web-server you'll need to make sure Fedora and SOLR are running.

Start Fedora and SOLR via jetty:

```console
bundle exec rake curatend:jetty:start
```

Start MySQL:

```console
mysql.server start
```

### 2. Initialize the database
Load the database schema into MySQL:
```console
bundle exec rake db:drop db:create db:schema:load
```
Seed the database with authority groups to give yourself access to the app:
```console
bundle exec rake db:seed
```

Optional: seed database with sample data:
```console
bundle exec rake db:seed:dev
```

### 3. Start Rails

In most cases, you will need SSL, so use this command:

```console
bin/rails s
```

You will need to go to `http://localhost:3000` (yes HTTP, not HTTPS even though SSL is running. Its a new Rails behavior)

## Release Documentation

See the [release documentation](https://docs.google.com/a/nd.edu/document/d/16weRctSzt8Iw2y55nwOKPBSgGDO_4lgti3CxaW3P2pc/edit?usp=sharing) for building a release.

## Automated Testing
Testing specs for [curate.nd.edu](http://curate.nd.edu) run with [BrowserStack open source program](https://www.browserstack.com/open-source?ref=pricing)


[![BrowserStack](app/assets/images/Browserstack-logo@2x.png)](https://www.browserstack.com)
