require 'spec_helper'

describe Tos do

  # get oauth tokens for different users
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      @public_oauth_token = SfdcHelper.public_access_token
    end
  end 

  describe "find tos" do
	  it "should return a tos correctly" do
      VCR.use_cassette "models/tos/all" do
        results = Tos.all(@public_oauth_token)
        @tos_id = results.first['id']
      end      
	    VCR.use_cassette "models/tos/find" do
        puts "=== finding tos id: #{@tos_id}"
	      results = Tos.find(@public_oauth_token, @tos_id)
	      results.should have_key('terms')
	      results.should have_key('default_tos')
	      results.should have_key('name')
	    end
	  end
  end  	

  describe "'all' tos" do
    it "should return a collection with correct keys" do
      VCR.use_cassette "models/tos/all" do
        results = Tos.all(@public_oauth_token)
        results.first.should have_key('id')
        results.first.should have_key('name')
        results.first.should have_key('terms')
        results.first.should have_key('default_tos')
      end
    end
  end     

end