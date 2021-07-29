# Deploying application

This document describes how the application itself is deployed. It does not
cover the steps necessary to setup the target system. Deploys to Preproduction
and Production are done through Jenkins. Deploys to Staging can be done by any
developer.

# Staging Deploys

You can deploy to any staging machine either through Jenkins or from your command line.
If you want to deploy from the command line, you will need to have given your public ssh key
to the Library ESU Group.

### To deploy your working branch to curate-test1

    cap staging deploy -s host=curate-test1.library.nd.edu -s branch=my-working-branch-name

### To deploy the tag `v2013.4` to curate-test1

set either the `branch` or the `tag` variable:

    cap staging deploy -s host=curate-test1.library.nd.edu -s branch=v2013.4

or

    cap staging deploy -s host=curate-test1.library.nd.edu -s tag=v2013.4

### To restart the application on curate-test1

    cap staging deploy:restart -s host=curate-test1.library.nd.edu

### To inspect the logs on curate-test1

    ssh app@curate-test1.library.nd.edu


. The application is deployed to `~/curatend/current`. The logs are
in `~/curatend/current/logs/staging.log`. There are many logs:

    Rails log: ~app/curatend/current/log/staging.log
    Unicorn Access log: ~app/curatend/current/log/unicorn.stdout.log
    Unicorn Error log: ~app/curatend/current/log/unicorn.stderr.log
    Resque Pool logs: ~app/curatend/current/log/resque-pool.stdout.log
                      ~app/curatend/current/log/resque-pool.stderr.log
    Nginx log:  /var/opt/rh/rh-nginx*/log/nginx/*log
    Fedora log: /opt/fedora/3.8.1/server/logs/fedora.log
    Solr log: As of Oct 2020, Solr logs for staging on on the curatesolr-prep server


