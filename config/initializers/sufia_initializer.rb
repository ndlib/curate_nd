require 'curate/jobs/content_deposit_event_job'
require 'sufia/models'
#gem 'sufia-models'
# Returns an array containing the vhost 'CoSign service' value and URL
Sufia.config do |config|
  config.after_create_content = lambda {|generic_file, user|
    Sufia.queue.push(Curate::ContentDepositEventJob.new(generic_file.pid, user.user_key))
  }
  config.enable_ffmpeg = false
  config.ffmpeg_path = 'ffmpeg'
  config.fits_message_length = 5
  config.temp_file_base = nil
  config.enable_contact_form_delivery = false
  config.dropbox_api_key = nil
  config.enable_local_ingest = nil
  require 'sufia/models/resque'
  config.queue = Sufia::Resque::Queue

  config.id_namespace = "und"
  config.fits_path = begin
    Rails.configuration.fits_path
  rescue NoMethodError
    "fits.sh"
  end
  config.fits_to_desc_mapping = begin
    Rails.configuration.fits_to_desc_mapping
  rescue NoMethodError => e
    { file_title: :title, file_author: :creator }
  end

  config.noid_template = '.reeddeeddedk'

  # try to load a noids server configuration
  # but it is okay if it doesn't exist
  config.noids = begin
                   {
                     server: ENV.fetch('NOIDS_SERVER'),
                     pool: ENV.fetch("NOIDS_POOL")
                   }
                 rescue KeyError
                   # file doesn't exist
                   # or yaml file does not define the current environment
                   nil
                 end

  config.max_days_between_audits = 7

  config.cc_licenses = {
    'CC BY 4.0' => 'https://creativecommons.org/licenses/by/4.0/',
    'CC BY-SA 4.0' => 'https://creativecommons.org/licenses/by-sa/4.0/',
    'CC BY-ND 4.0' => 'https://creativecommons.org/licenses/by-nd/4.0/',
    'CC BY-NC 4.0' => 'https://creativecommons.org/licenses/by-nc/4.0/',
    'CC BY-NC-SA 4.0' => 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
    'CC BY-NC-ND 4.0' => 'https://creativecommons.org/licenses/by-nc-nd/4.0/',
    'Attribution 3.0 United States' => 'http://creativecommons.org/licenses/by/3.0/us/',
    'Attribution-ShareAlike 3.0 United States' => 'http://creativecommons.org/licenses/by-sa/3.0/us/',
    'Attribution-NonCommercial 3.0 United States' => 'http://creativecommons.org/licenses/by-nc/3.0/us/',
    'Attribution-NoDerivs 3.0 United States' => 'http://creativecommons.org/licenses/by-nd/3.0/us/',
    'Attribution-NonCommercial-NoDerivs 3.0 United States' => 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/',
    'Attribution-NonCommercial-ShareAlike 3.0 United States' => 'http://creativecommons.org/licenses/by-nc-sa/3.0/us/',
    'Public Domain Mark 1.0' => 'http://creativecommons.org/publicdomain/mark/1.0/',
    'CC0 1.0 Universal' => 'http://creativecommons.org/publicdomain/zero/1.0/',
    'All rights reserved' => 'All rights reserved'
  }

  config.cc_licenses_reverse = Hash[*config.cc_licenses.to_a.flatten.reverse]

  config.permission_levels = {
    "Choose Access"=>"none",
    "View/Download" => "read",
    "Edit" => "edit"
  }

  config.owner_permission_levels = {
    "Edit" => "edit"
  }

  config.queue = Sufia::Resque::Queue

  # Map hostnames onto Google Analytics tracking IDs
  #config.google_analytics_id = 'UA-99999999-1'
end

Hydra::Derivatives.ffmpeg_path    = Sufia.config.ffmpeg_path
Hydra::Derivatives.temp_file_base = Sufia.config.temp_file_base
Hydra::Derivatives.fits_path      = Sufia.config.fits_path
Hydra::Derivatives.enable_ffmpeg  = Sufia.config.enable_ffmpeg

require 'hydra/head'
require 'nest'
require 'mailboxer'
require 'acts_as_follower'
require 'paperclip'
require 'resque/server'
require 'sufia/models/active_fedora/redis'
require 'sufia/models/active_record/redis'
require 'sufia/models/active_record/deprecated_attr_accessible'
require 'activerecord-import'
require 'hydra/derivatives'
require 'sufia/models/model_methods'
require 'sufia/models/noid'
require 'sufia/models/file_content'
require 'sufia/models/file_content/versions'
require 'sufia/models/generic_file/audit'
require 'sufia/models/generic_file/characterization'
require 'sufia/models/generic_file/derivatives'
require 'sufia/models/generic_file/export'
require 'sufia/models/generic_file/mime_types'
require 'sufia/models/generic_file/thumbnail'
require 'sufia/models/generic_file'
require 'sufia/models/user_local_directory_behavior'
require 'sufia/models/id_service'
require 'sufia/models/solr_document_behavior'
