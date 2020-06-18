#
# Tasks specific to CurateND
#

namespace :curatend do
  # don't define the ci stuff in production...since rspec is not available
    def system_with_command_output(command)
      puts("\n$\t#{command}")
      system(command)
    end
    namespace :jetty do
      JETTY_ZIP_BASENAME = 'xacml-updates-for-curate-with-solr-updates'
      JETTY_URL = "https://github.com/ndlib/hydra-jetty/archive/#{JETTY_ZIP_BASENAME}.zip"
      JETTY_ZIP = Rails.root.join('spec', JETTY_URL.split('/').last).to_s
      JETTY_DIR = Rails.root.join('jetty').to_s

      task :download do
        puts "Downloading jetty..."
        if File.exist?(JETTY_ZIP)
          puts "File already exists, moving on..."
        else
          system_with_command_output "curl -L #{JETTY_URL} -o #{JETTY_ZIP}"
          abort "Unable to download jetty from #{JETTY_URL}" unless $?.success?
        end
      end

      task :unzip do
        puts "Unpacking jetty..."
        tmp_save_dir = Rails.root.join('spec', 'jetty_generator').to_s
        system_with_command_output "unzip -d #{tmp_save_dir} -qo #{JETTY_ZIP}"
        abort "Unable to unzip #{JETTY_ZIP} into #{tmp_save_dir}" unless $?.success?

        expanded_dir = File.join(tmp_save_dir, "hydra-jetty-#{JETTY_ZIP_BASENAME}")
        system_with_command_output "mv #{File.join(expanded_dir, '/*')} #{JETTY_DIR}"
        abort "Unable to move #{expanded_dir} into #{JETTY_DIR}/" unless $?.success?
      end

      task :clean do
        system_with_command_output "rm -rf #{JETTY_DIR} && mkdir -p #{JETTY_DIR}"
      end

      desc 'Download the appropriate jetty instance and install it with proper configuration'
      task :init => ["curatend:jetty:download", "curatend:jetty:clean", "curatend:jetty:unzip"]

      desc 'Download jetty instance and start it'
      task :start => ['curatend:jetty:init'] do
        Rake::Task['jetty:start'].invoke
      end

      desc 'Stop the jetty instance'
      task :stop do
        Rake::Task['jetty:stop'].invoke
      end
    end

    desc "Execute Continuous Integration build (docs, tests with coverage)"
    task :ci => ["environment", "curatend:ci_spec", 'curatend:lint_erb']

    desc "Prepare environment for CI"
    task :ci_prep => :environment do
      Rake::Task["db:drop"].invoke rescue true
      Rake::Task["db:create"].invoke
      Rake::Task['db:schema:load'].invoke
    end

    if defined?(RSpec)
      RSpec::Core::RakeTask.new(:ci_spec) do |t|
        t.pattern = "./spec/**/*_spec.rb"
      end
    end

    desc "Lint ERB templates"
    task lint_erb: :environment do
      returning_value = system("cd #{Rails.root.join('app/views')} && bundle exec rails-erb-lint check")
      abort "There were linting errors in the ERB templates. See above message(s)." unless returning_value
    end
end
