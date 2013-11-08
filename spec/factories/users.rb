# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "username-#{n}" }
    agreed_to_terms_of_service true
    user_does_not_require_profile_update true

    factory :user_with_person do
      initialize_with { |*args|
        user = FactoryGirl.build(:user)
        account = Account.new(user, attributes)
        account.save
        account.user
      }
    end

    after(:create) do |user, evaluator|
      UserWhitelist.new(username: user.username).save!
    end
  end

  factory :account do
    user { FactoryGirl.build(:user) }
    sequence(:username) {|n| "username-#{n}" }
    initialize_with {|*args|
      new( user, attributes )
    }
    after(:create) do |account, evaluator|
      account.save
    end
  end
end
