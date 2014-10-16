class Curate::OrcidMigration
  def self.migrate!
    User.where("orcid_id IS NOT NULL AND orcid_id != ''").each do |user|
      begin
        Orcid::ProfileConnection.new(user: user, orcid_profile_id: user.orcid_id).save
      rescue ActiveRecord::RecordNotUnique
        puts "User with orcid_id: #{user.orcid_id} already exists"
      end
    end
  end
end
