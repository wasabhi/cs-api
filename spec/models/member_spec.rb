require 'spec_helper'

describe Member do

  # get oauth tokens for different users
  before(:all) do
    puts "[SETUP] fetching new access tokens....."
    VCR.use_cassette "models/accounts/get_public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
    end

    VCR.use_cassette "models/accounts/get_admin_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @admin_oauth_token = client.authenticate :username => ENV['SFDC_ADMIN_USERNAME'], :password => ENV['SFDC_ADMIN_PASSWORD']
    end
  end 	

  describe "all" do
	  it "should return members successfully" do
	    VCR.use_cassette "models/members/all_members" do
	      results = Member.all(@public_oauth_token, 'id,name', 'name')
	      # should return an array
	      results.count.should > 0
	    end
	  end
  end  

  describe "search" do
	  it "should return jeffdonthemic successfully" do
	    VCR.use_cassette "models/members/search_jeffdonthemic" do
	      results = Member.search(@public_oauth_token, 'jeffdonthemic', 'id,name')
	      # should return an array
	      results.count.should > 0
	      results.first['name'].should == 'jeffdonthemic'
	    end
	  end

	  it "should not return a non-existent member" do
	    VCR.use_cassette "models/members/search_unknown" do
	      results = Member.search(@public_oauth_token, 'novaliduser', 'id,name')
	      # should return an array
	      results.count.should == 0
	    end
	  end	  
  end  

  describe "challenges" do
	  it "should return challenges successfully for a member" do
	    VCR.use_cassette "models/members/challenges_jeffdonthemic" do
	      results = Member.challenges(@public_oauth_token, 'jeffdonthemic')
	      # should return an array
	      results.count.should > 0
	    end
	  end
	  it "should not return challenges successfully for a non-existent member" do
	    VCR.use_cassette "models/members/challenges_novaliduser" do
	      results = Member.challenges(@public_oauth_token, 'novaliduser')
	      # should return an array
	      results.count.should == 0
	    end
	  end	  
  end    

  describe "find by membername" do
	  it "should return jeffdonthemc" do
	    VCR.use_cassette "models/members/find_jeffdonthemic" do
	      results = Member.find_by_membername(@public_oauth_token, 'jeffdonthemic', 'id,name')
	      # should return an array
	      results.count.should == 1
	      results.first.should have_key('name')
	      results.first.should have_key('id')
	      results.first['name'].should == 'jeffdonthemic'
	    end
	  end
	  it "should not return a non-existent member" do
	    VCR.use_cassette "models/members/find_novaliduser" do
	      results = Member.find_by_membername(@public_oauth_token, 'novaliduser', 'id,name')
	      # should return an array
	      results.count.should == 0
	    end
	  end	  
  end    

  describe "update member" do
	  it "should update successfully" do
	    VCR.use_cassette "models/members/update_success" do
	      results = Member.update(@public_oauth_token, 'jeffdonthemic', {'Jabber__c' => 'somejabbername'})
        results[:success].should == 'true'
	    end
	    # make sure it was updated successfully
	    VCR.use_cassette "models/members/update_success_check" do
        results2 = Member.find_by_membername(@public_oauth_token, 'jeffdonthemic', 'jabber__c')
        results2.first['jabber'].should == 'somejabbername'
	    end
	  end
	  it "should not update successfully with a bad field" do
	    VCR.use_cassette "models/members/update_failure" do
	      results = Member.update(@public_oauth_token, 'jeffdonthemic', {'Email__c' => 'bademail'})
        results[:success].should == 'false'
        results[:message].should == 'Email: invalid email address: bademail'
	    end
	  end
	  it "should not update successfully an unknown" do
	    VCR.use_cassette "models/members/update_failure_unknown" do
	      results = Member.update(@public_oauth_token, 'badrspecuser', {'Email__c' => 'bademail'})
        results[:success].should == 'false'
        results[:message].should == 'Member not found for: badrspecuser'
	    end
	  end	  
  end  

  describe "payments" do
	  it "should return payments successfully" do
	    VCR.use_cassette "models/members/payments_success" do
	      results = Member.payments(@public_oauth_token, 'jeffdonthemic', 'id,name', 'name')
	      # should return an array
	      results.count.should >= 0
	      results.first.should have_key('name')
	      results.first.should have_key('id')	      
	    end
	  end
  end

  describe "recommendations" do
	  it "should return recommendations successfully" do
	    VCR.use_cassette "models/members/recommendations_success" do
	      results = Member.recommendations(@public_oauth_token, 'jeffdonthemic', 'id,name')
	      # should return an array
	      results.count.should >= 0
	      results.first.should have_key('name')
	      results.first.should have_key('id')	      
	    end
	  end

	  it "should create a recommendation successfully" do
	    VCR.use_cassette "models/members/recommendations_create_success" do
	      results = Member.recommendation_create(@public_oauth_token, 'jeffdonthemic', 'mess', 'my comment')
        results[:success].should == 'true'
        results[:message].should_not be_empty
	    end
	  end	  

	  it "should return error when it cannot create a recommendation" do
	    VCR.use_cassette "models/members/recommendations_create_failure" do
	      results = Member.recommendation_create(@public_oauth_token, 'jeffdonthemic', 'mess', '')
        results[:success].should == 'false'
        results[:message].should == 'Required parameters are missing. You must pass values for the following: recommendation_for_username, recommendation_from_username, recommendation_text.'
	    end
	  end	  	  
  end  

end