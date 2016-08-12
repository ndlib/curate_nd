#!/bin/bash

# Run bendo:sync_with fedora rake task, from application root directory,
# using RAILS_ENV

cd /home/app/curatend/current

# source our ruby env, and rails env
source /etc/profile.d/ruby.sh
source ./env-vars

/opt/ruby/current/bin/bundle exec rake RAILS_ENV=$RAILS_ENV bendo:sync_with_fedora 2>&1 >>/home/app/curatend/shared/log/bendo-sync.log
