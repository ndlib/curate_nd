require 'senior_thesis'
require 'generic_file'
require 'downloads_controller'
require 'curation_concern/senior_theses_controller'
ActivityEngine.register_models("SeniorThesis", "GenericFile", 'User')
ActivityEngine.register_controller('DownloadsController', 'show')
ActivityEngine.register_controller('CurationConcern::SeniorThesesController', 'create')
ActivityEngine.register_controller('UsersController', 'update')

ActivityEngine.register('DownloadsController', 'show') do |activity,context|
  activity.subject = context.generic_file
  activity.current_user = context.current_user
  activity.activity_type = "downloads#show"
end
