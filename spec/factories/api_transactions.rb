# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api_transaction, :class => 'ApiTransactions' do
    status "MyString"
    user nil
  end
end
