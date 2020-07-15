# frozen_string_literal: true

# List all tasks from RAILS_ROOT using: cap -T
#
# NOTE: The SCM command expects to be at the same path on both the local and
# remote machines. The default git path is: '/shared/git/bin/git'.

set :bundle_roles, %i[app work]
set :bundle_flags, '--deployment'
require 'bundler/capistrano'
# see http://gembundler.com/v1.3/deploying.html
# copied from https://github.com/carlhuda/bundler/blob/master/lib/bundler/deployment.rb
#
# Install the current Bundler environment. By default, gems will be \
#  installed to the shared/bundle path. Gems in the development and \
#  test group/symlink will not be installed. The install command is executed \
#  with the --deployment and --quiet flags. If the bundle cmd cannot \
#  be found then you can override the bundle_cmd variable to specifiy \
#  which one it should use. The base path to the app is fetched from \
#  the :latest_release variable. Set it for custom deploy layouts.
#
#  You can override any of these defaults by setting the variables shown below.
#
#  N.B. bundle_roles must be defined before you require 'bundler/#{context_name}' \
#  in your deploy.rb file.
#
#    set :bundle_gemfile,  "Gemfile"
#    set :bundle_dir,      File.join(fetch(:shared_path), 'bundle')
#    set :bundle_flags,    "--deployment --quiet"
#    set :bundle_without,  [:development, :test]
#    set :bundle_cmd,      "/opt/rh/rh-ruby26/root/usr/local/bin/bundle" # e.g. "bundle"
#    set :bundle_roles,    #{role_default} # e.g. [:app, :batch]
#############################################################
#  Settings
#############################################################

default_run_options[:pty] = true
set :use_sudo, false
ssh_options[:paranoid] = false
set :default_shell, '/bin/bash'

#############################################################
#  SCM
#############################################################

set :scm, :git
set :deploy_via, :remote_cache

#############################################################
#  Environment
#############################################################

namespace :env do
  desc 'Set command paths'
  task :set_paths do
    set :bundle_cmd, '/opt/rh/rh-ruby26/root/usr/local/bin/bundle'
    set :rake, "#{bundle_cmd} exec rake"
  end
end

#############################################################
#  Unicorn
#############################################################

desc 'Restart Application'
task :restart_unicorn, roles: :app do
  run "#{current_path}/script/reload-unicorn.sh"
end

#############################################################
#  Database
#############################################################

namespace :db do
  desc 'Run the seed rake task.'
  task :seed, roles: :app do
    run "cd #{release_path}; #{rake} RAILS_ENV=#{rails_env} db:seed"
  end
end

#############################################################
#  Deploy
#############################################################

namespace :deploy do
  desc 'Execute various commands on the remote environment'
  task :debug, roles: :app do
    run '/usr/bin/env', pty: false, shell: '/bin/bash'
    run 'whoami'
    run 'pwd'
    run 'echo $PATH'
    run 'which ruby'
    run 'ruby --version'
    run 'which rake'
    run 'rake --version'
    run 'which bundle'
    run 'bundle --version'
    run 'which git'
  end

  desc 'Start application in Passenger'
  task :start, roles: :app do
    restart_unicorn
  end

  desc 'Restart application in Passenger'
  task :restart, roles: :app do
    restart_unicorn
  end

  task :stop, roles: :app do
    # Do nothing.
  end

  desc 'Run the migrate rake task.'
  task :migrate, roles: :app do
    run "cd #{release_path}; #{rake} RAILS_ENV=#{rails_env} db:migrate"
  end

  desc 'Symlink shared configs and folders on each release.'
  task :symlink_shared do
    symlink_targets.each do |source, destination, shared_directory_to_create|
      run "mkdir -p #{File.join(shared_path, shared_directory_to_create)}"
      run "ln -nfs #{File.join(shared_path, source)} #{File.join(release_path, destination)}"
    end
  end

  desc 'Spool up a request to keep user experience speedy'
  task :kickstart, roles: :app do
    run "curl -I -k https://#{domain}"
  end

  desc 'Precompile assets'
  task :precompile, roles: :app do
    run "cd #{release_path}; #{rake} RAILS_ENV=#{rails_env} RAILS_GROUPS=assets assets:precompile"
  end

  desc 'Setup application symlinks for shared assets'
  task :symlink_setup, roles: %i[app web] do
    shared_directories.each { |link| run "mkdir -p #{shared_path}/#{link}" }
  end

  desc 'Link assets for current deploy to the shared location'
  task :symlink_update do
    (shared_directories + shared_files).each do |link|
      run "ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"
    end
  end
end

namespace :worker do
  task :start, roles: :work do
    # TODO: this file contains the same information as the env-vars file created in und:write_env_vars
    # make a distinction here until we remove the old cluster stuff
    target_file =
      if %w[staging pre_production production].include?(rails_env)
        '/home/app/curatend/resque-pool-info'
      else
        '/home/curatend/resque-pool-info'
      end
    # the file this writes is essentially the same as the one created
    # by und:write_env_vars
    run [
      "echo \"RESQUE_POOL_ROOT=#{current_path}\" > #{target_file}",
      "echo \"RESQUE_POOL_ENV=#{fetch(:rails_env)}\" >> #{target_file}",
      'sudo /sbin/service resque-poold restart'
    ].join(' && ')
  end
end

########################
# solr
#########################

namespace :solr do
  task :configure, roles: :app do
    # this pulls the solr config off the remote machine, parses the yml
    # then tells the remote machine to copy the solr config to the server
    # via the global NFS mount, and then pings the solr server to restart it.
    config = capture("cat #{current_path}/config/solr.yml")
    require 'uri'
    solr_core_url = YAML.safe_load(config).fetch(rails_env).fetch('url')
    uri = URI.parse(solr_core_url)
    solr_url_reload = "#{uri.scheme}://#{uri.host}:#{uri.port}/solr/admin/cores\?action=RELOAD\&core=curate"
    run "cp -rf #{current_path}/#{src_solr_confdir}/* #{dest_solr_confdir}"
    run "curl #{solr_url_reload}"
  end
end

namespace :maintenance do
  task :create_person_records, roles: :app do
    run "cd #{current_path} && bundle exec rails runner #{File.join(current_path, 'script/sync_person_with_user.rb')} -e #{rails_env}"
  end
  task :delete_index_solr, roles: :app do
    config = capture("cat #{current_path}/config/solr.yml")
    solr_core_url = YAML.safe_load(config).fetch(rails_env).fetch('url')
    run "curl #{File.join(solr_core_url, 'update')}?commit=true -H 'Content-Type:application/xml' -d '<delete><query>*:*</query></delete>'"
  end
  task :reindex_solr, roles: :app do
    run "cd #{current_path} && bundle exec rails runner 'Sufia.queue.push(ReindexWorker.new)' -e #{rails_env}"
  end

  task :migrate_person, roles: :app do
    run "cd #{current_path} && bundle exec rails runner 'Migrator.enqueue' -e #{rails_env}"
  end
  task :migrate_metadata, roles: :app do
    command = "Curate::MigrationServices.enqueue(migration_container_module_name: 'MetadataNormalization')"
    run "cd #{current_path} && bundle exec rails runner -e #{rails_env} \"#{command}\""
  end

  task :vanilla_to_nd_schema, roles: :app do
    run "cd #{current_path} && bundle exec rails runner -e #{rails_env} script/transform_schema_of_vanilla_to_nd.rb"
  end

  task :update_profile_section_to_open_access, roles: :app do
    run "cd #{current_path} && bundle exec rails runner -e #{rails_env} script/update_profile_section_to_open_access.rb"
  end

  desc 'Run ORCID migrations for data'
  task :orcid_migration, roles: :app do
    run "cd #{current_path} && bundle exec rails runner -e #{rails_env} script/migrations/orcid_migration.rb"
  end

  desc 'Run ETD Reindexing'
  task :etd_reindex, roles: :app do
    run "cd #{current_path} && bundle exec rails runner -e #{rails_env} 'Etd.all.each(&:update_index)'"
  end
end

namespace :und do
  task :update_secrets do
    run "cd #{release_path} && ./script/update_secrets.sh"
  end

  desc 'Write the current environment values to file on targets'
  task :write_env_vars do
    put %(RAILS_ENV=#{rails_env}
RAILS_ROOT=#{current_path}
), "#{release_path}/env-vars"
  end

  task :write_build_identifier do
    put branch.to_s, "#{release_path}/BUILD_IDENTIFIER"
  end

  desc 'Have all new requests to be redirected to a 503 page'
  task :show_maintenance, roles: :web do
    run "touch #{shared_path}/system/maintenance"
  end

  desc 'Allow requests to be handled as usual'
  task :hide_maintenance, roles: :web do
    run "rm -f #{shared_path}/system/maintenance"
  end
end

#############################################################
#  Callbacks
#############################################################

before 'deploy', 'env:set_paths'

#############################################################
#  Configuration
#############################################################

set :application, 'curate_nd'
set :repository,  'git://github.com/ndlib/curate_nd.git'

#############################################################
#  Environments
#############################################################

desc 'Setup for staging VM'
task :staging do
  # can also set :branch with the :tag variable
  set :branch,    fetch(:branch, fetch(:tag, 'master'))
  set :rails_env, 'staging'
  set :deploy_to, '/home/app/curatend'
  set :user,      'app'
  set :domain,    fetch(:host, 'libvirt6.library.nd.edu')
  set :bundle_without, %i[development test debug]
  set :shared_directories, %w[log]
  set :shared_files, %w[]

  default_environment['PATH'] = '/opt/ruby/current/bin:$PATH'
  server "#{user}@#{domain}", :app, :work, :web, :db, primary: true

  after 'deploy:update_code', 'und:write_env_vars', 'und:write_build_identifier', 'und:update_secrets', 'deploy:symlink_update', 'deploy:migrate', 'db:seed', 'deploy:precompile'
  after 'deploy', 'deploy:cleanup'
  after 'deploy', 'deploy:kickstart'
  after 'deploy', 'worker:start'
end

desc 'Setup for pre-production deploy'
# new one
task :pre_production do
  set :branch,    fetch(:branch, fetch(:tag, 'master'))
  set :rails_env, 'pre_production'
  set :deploy_to, '/home/app/curatend'
  set :user,      'app'
  set :domain,    fetch(:host, 'curatesvrpprd')
  set :bundle_without, %i[development test debug]
  set :shared_directories, %w[log]
  set :shared_files, %w[]
  set :src_solr_confdir, 'solr_conf/conf'
  set :dest_solr_confdir, '/global/data/solr/pre_production/curate/conf'

  default_environment['PATH'] = '/opt/ruby/current/bin:$PATH'
  server 'app@curatesvrpprd.lc.nd.edu', :app, :web, :db, primary: true
  server 'app@curatewkrpprd.lc.nd.edu', :work, primary: true

  before 'bundle:install', 'solr:configure'
  after 'deploy:update_code', 'und:write_env_vars', 'und:write_build_identifier', 'und:update_secrets', 'deploy:symlink_update', 'deploy:migrate', 'db:seed', 'deploy:precompile'
  after 'deploy', 'deploy:cleanup'
  after 'deploy', 'deploy:kickstart'
  after 'deploy', 'worker:start'
end

desc 'Setup for production deploy'
# new one
task :production do
  set :branch,    fetch(:branch, fetch(:tag, 'master'))
  set :rails_env, 'production'
  set :deploy_to, '/home/app/curatend'
  set :user,      'app'
  set :domain,    fetch(:host, 'curatesvrprod')
  set :bundle_without, %i[development test debug]

  set :shared_directories, %w[log]
  set :shared_files, %w[]
  set :src_solr_confdir, 'solr_conf/conf'
  set :dest_solr_confdir, '/global/data/solr/production/curate/conf'

  default_environment['PATH'] = '/opt/ruby/current/bin:$PATH'
  server 'app@curatesvrprod.lc.nd.edu', :app, :web, :db, primary: true
  server 'app@curatewkrprod.lc.nd.edu', :work, primary: true

  before 'bundle:install', 'solr:configure'
  after 'deploy:update_code', 'und:write_env_vars', 'und:write_build_identifier', 'und:update_secrets', 'deploy:symlink_update', 'deploy:migrate', 'db:seed', 'deploy:precompile'
  after 'deploy', 'deploy:cleanup'
  after 'deploy', 'deploy:kickstart'
  after 'deploy', 'worker:start'
end
