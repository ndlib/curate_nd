class SyncPersonWithUser
  def self.sync
    User.all.each do |user|
      Person.find_or_create_by_user(user)
    end
  end
end
