class V1::AccountsController < V1::ApplicationController

	before_filter :restrict_access

  #
  # Post method to create a new member in db.com and send welcome email
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - params -> hash containing values to use for new user
  #      - for third-party: provider, provider_username, username, email, name (can be blank)
  #      - for cloudspokes: username, email, password 
  # * *Returns* :
  #   - JSON containing the following keys: username, sfdc_username, success, message 
  # * *Raises* :
  #   - ++ ->
  #  
  def create
    expose Account.create(@oauth_token, params)
  end

  #
  # Post method to authenticates a membername and password against db.com.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess)
  #   - password -> the db.com password
  # * *Returns* :
  #   - JSON containing the following keys: access_token, success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def authenticate
    expose Account.authenticate(@oauth_token, params[:membername], params[:password])
  end

  #
  # Finds a user by their membername and service ('cloudspokes' or third party).
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess) to find
  #   - service -> the thirdparty or 'cloudspokes' service
  # * *Returns* :
  #   - JSON containing the following keys: username, sfdc_username, success
  #     profile_pic, email and accountid
  # * *Raises* :
  #   - ++ ->
  #  
  def find
    expose Account.find_by_membername_and_service(@oauth_token, params[:membername], params[:service])
  end

  #
  # Creates a passcode in salesforce for resetting a member's password and sends email via Apex. 
  # Only works if member is using CloudSpokes to manage their account.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess) to reset
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def reset_password
    expose Account.reset_password(@oauth_token, params[:membername])
  end

  #
  # Resets a member's password in salesforce is CloudSpokes is managing their account.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess) to reset
  #   - passcode -> the passcode sent to them via email
  #   - new_password -> the new password to change their account to
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def update_password
    expose Account.update_password(@oauth_token, params[:membername], params[:passcode], params[:new_password])
  end  

end