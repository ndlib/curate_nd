#!/bin/bash

app_root=$(cd $(dirname $0)/.. && pwd)

env_file=$app_root/env-vars

if [ -f $env_file ]; then
    source $env_file
fi

# set defaults.
# the `true` command is just a placeholder.  the defaults are set in the
# parameter expansions (only if the variables are not otherwise set!)
true ${RAILS_ENV=qa} ${RAILS_ROOT=$app_root}

export RAILS_ENV RAILS_ROOT

