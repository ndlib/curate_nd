#!/bin/bash

# Starts the application server. It assumes
# there is an nginx reverse proxy at port 80

export PATH=/opt/rh/rh-ruby26/root/usr/local/bin:$PATH

source /home/app/curatend/current/script/get-env.sh
cd $RAILS_ROOT
bundle exec unicorn -D -E $RAILS_ENV -c $RAILS_ROOT/config/unicorn.rb
