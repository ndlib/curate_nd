class MockFile < Rack::Test::UploadedFile
  attr_accessor :fake_file_name
  # Override this method so that we can provide a fake file name.
  # Several views depend on the datastream label, which is just the
  # the original_filename of the file. This allows you to effectively
  # change what label is displayed in those views. Otherwise, you will
  # see the same label for every file.
  def original_filename
    fake_file_name || super
  end
end

# Creates a new user without duplicating usernames
def create_user(email, name, pw)
  user = User.find_or_create_by(username: name) do |u|
    u.email = email
    u.username = name
    u.password = pw
    u.password_confirmation = pw
  end
  user
end

# Creates a new account associated with a user
def create_account(user)
  account = Account.to_adapter.get!(user.id)
  update_status = account.update_with_password({ "email" => user.email, "name" => user.username })
end

# Creates or finds an object by id. If an actor is given, will use the actor to create
# the object. Otherwise, will just use the new method on the model given
def find_or_create(model, actor, id, user, params)
  curation_concern = model.where(desc_metadata__identifier_tesim: id).first
  if curation_concern.nil?
    curation_concern = model.new(identifier: id)
    if actor.present?
      actor.new(curation_concern, user, params).create
    else
      curation_concern.attributes = params
      curation_concern.apply_depositor_metadata(user.user_key)
      curation_concern.save!
    end
  end
  curation_concern
end

# Shared variables
user_with_profile = create_user('userwithprofile@example.com', 'userwithprofile', 'foobarbaz')
create_account(user_with_profile)
user_without_profile = create_user('userwithoutprofile@example.com', 'userwithoutprofile', 'foobarbaz')
seeds_file = MockFile.new(__FILE__, 'text/plain', false)

print "Things with no files\n"
attributes = { creator: user_with_profile.username, abstract: 'Article abstract', title: 'Article with no files' }
print "#{attributes[:title]}\n"
find_or_create(Article, CurationConcern::ArticleActor, 'article_with_no_files', user_with_profile, attributes)

# TODO: This is currently duplicating. Need to figure out what field to use for find in find_or_create
attributes = { creator: user_with_profile.username, description: 'Audio description', title: 'Audio with no files' }
print "#{attributes[:title]}\n"
find_or_create(Audio, CurationConcern::AudioActor, 'audio_with_no_files', user_with_profile, attributes)

attributes = { creator: user_with_profile.username, title: 'Catholic Document with no files' }
print "#{attributes[:title]}\n"
find_or_create(CatholicDocument, CurationConcern::CatholicDocumentActor, 'catholicdoc_with_no_files', user_with_profile, attributes)

attributes = { creator: user_with_profile.username, description: 'Dataset description', title: 'Dataset with no files' }
print "#{attributes[:title]}\n"
find_or_create(Dataset, CurationConcern::DatasetActor, 'dataset_with_no_files', user_with_profile, attributes)

attributes = { creator: user_with_profile.username, title: 'Document with no files' }
print "#{attributes[:title]}\n"
find_or_create(Document, CurationConcern::DocumentActor, 'document_with_no_files', user_with_profile, attributes)

attributes = { creator: user_with_profile.username, title: 'Finding Aid with no files' }
print "#{attributes[:title]}\n"
find_or_create(FindingAid, CurationConcern::FindingAidActor, 'findingaid_with_no_files', user_with_profile, attributes)

attributes = { creator: user_with_profile.username, description: 'Image description', title: 'Image with no files' }
print "#{attributes[:title]}\n"
find_or_create(Image, CurationConcern::ImageActor, 'image_with_no_files', user_with_profile, attributes)

# TODO: There is no :identifier field on patents. Can't use current implementation of find_or_create
#attributes = { creator: user_with_profile.username, description: 'Patent description', title: 'Patent with no files' }
#print "#{attributes[:title]}\n"
#find_or_create(Patent, CurationConcern::PatentActor, 'patent_with_no_files', user_with_profile, attributes)

attributes = { creator: user_with_profile.username, description: 'Senior Thesis description', title: 'Senior Thesis with no files' }
print "#{attributes[:title]}\n"
find_or_create(SeniorThesis, CurationConcern::SeniorThesisActor, 'seniorthesis_with_no_files', user_with_profile, attributes)

attributes = { creator: user_with_profile.username, description: 'Video description', title: 'Video with no files' }
print "#{attributes[:title]}\n"
find_or_create(Video, CurationConcern::VideoActor, 'video_with_no_files', user_with_profile, attributes)

print "Things with files\n"
article_attributes = { creator: user_with_profile.username, abstract: 'Abstract', title: 'Article with many files' }
print "#{attributes[:title]}\n"
article = find_or_create(Article, CurationConcern::ArticleActor, 'article_with_many_files', user_with_profile, article_attributes)
15.times do |i|
  seeds_file.fake_file_name = "article_with_many_files.generic_files_#{i}"
  file_attributes = { batch: article, file: seeds_file }
  file = find_or_create(GenericFile, CurationConcern::GenericFileActor, "article_with_many_files.generic_file_#{i}", user_with_profile, file_attributes)
end
