require 'spec_helper'

describe LdapService do
  let(:user){
    user = User.new
    user.username = "test.user"
  }

  let(:invalid_user){
    invalid_user = User.new
    invalid_user.username = "test.use"
  }

  let(:returned_result) { { :mail => [ "Test.User@example.com" ], :displayName => [ "John Smith" ] } }

  let(:ldap_service){
    @ldap_service = LdapService.new(user)
  }

  let(:another_ldap_service){
    @another_ldap_service = LdapService.new(invalid_user)
  }

  let(:expected_user_id) { "Test.User@example.com" }
  let(:expected_display_name) { "John Smith" }

  describe ".preferred_email" do
    it "should return preferred email" do
      ldap_service.stub(:ldap_lookup) { returned_result }
      ldap_service.preferred_email.should eq expected_user_id
    end

    it "should raise error for unknown users" do
      another_ldap_service.stub(:ldap_lookup) { nil }
      expect{another_ldap_service.preferred_email}.to raise_error(LdapService::UserNotFoundError)
    end

    it "should raise error for timeouts" do
      ldap_service.stub(:ldap_lookup) { raise Timeout::Error }
      expect{ldap_service.preferred_email}.to raise_error(Timeout::Error)
    end
  end

  describe ".display_name" do
   it "should return display_name" do
     ldap_service.stub(:ldap_lookup) { returned_result }
     ldap_service.display_name.should eq expected_display_name
   end

   it "should raise error for unknown users" do
     another_ldap_service.stub(:ldap_lookup) { nil }
     expect{another_ldap_service.display_name}.to raise_error(LdapService::UserNotFoundError)
   end

   it "should raise error for timeouts" do
     ldap_service.stub(:ldap_lookup) { raise Timeout::Error }
     expect{ldap_service.display_name}.to raise_error(Timeout::Error)
   end
  end

end
