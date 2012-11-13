class V1::ChallengesController < V1::ApplicationController

	before_filter :restrict_access, :only => [:create, :update]

	# inherit from actual challenge model. Challenges in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Challenge < ::Challenge

	end	

  #
  # Returns a specific challange, categories, prizes and terms
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - challenge_id -> the id of the challenge to fetch
  # * *Returns* :
  #   - JSON a challenge object containing a terms_of_service__r
  #   and collection of challenge_categories__r and challenge_prizes__r
  # * *Raises* :
  #   - ++ -> 404 if not found
  #  	
	def find
		challenge = Challenge.find(@oauth_token, params[:challenge_id].strip)
		error! :not_found unless challenge
		expose challenge
	end					

  #
  # Returns all currently open challenges
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - category (optional) -> the category of challenges to return. Defaults
	#	  to nil.	
  #   - order_by (optional) -> the field to order the results by. Defaults
	#	  to name.		
  # * *Returns* :
  #   - JSON a collection of challenge objects with challenge_categories__r 
  # * *Raises* :
  #   - ++ ->
  #  	
	def open
		expose Challenge.all(@oauth_token, 'true', 
			params[:category] ||= nil, 
			enforce_order_by_params(params[:order_by], 'name'))
	end	

  #
  # Returns all closed hallenges
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - category (optional) -> the category of challenges to return. Defaults
	#	  to nil.	
  #   - order_by (optional) -> the field to order the results by. Defaults
	#	  to name.		
  # * *Returns* :
  #   - JSON a collection of challenge objects with challenge_categories__r 
  # * *Raises* :
  #   - ++ ->
  #  	
	def closed
		expose Challenge.all(@oauth_token, 'false', 
			params[:category] ||= nil, 
			enforce_order_by_params(params[:order_by], 'name'))
	end		

  #
  # Returns all recently closed challenges with winners selected
  # * *Args*    :
  #   - access_token -> the oauth token to use	
  # * *Returns* :
  #   - JSON a collection of challenge objects with 
  #   challenge_categories__r and challenge_participants__r
  # * *Raises* :
  #   - ++ ->
  #  	
	def recent
		expose Challenge.recent(@oauth_token)
	end		

  #
  # Creates a new challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use	
  #   - params[:data] -> the JSON to use to create the
  #   challenge. See spec/data/create_challenge.json for example.
  # * *Returns* :
  #   - a hash containing the following keys: success, challenge_id, errors
  # * *Raises* :
  #   - ++ ->
  #  	
	def create
		expose Challenge.create(@oauth_token, params[:data])
	end			

  #
  # Updates an existing challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use	
  #   - params[:data] -> the JSON to use to update the
  #   challenge. See spec/data/update_challenge.json for example.
  # * *Returns* :
  #   - a hash containing the following keys: success, challenge_id, errors
  # * *Raises* :
  #   - ++ ->
  #  	
	def update
		expose Challenge.update(@oauth_token, params[:challenge_id].strip,
			params[:data])
	end	

  #
  # Returns a collection of participants for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - challenge_id -> the id of the challenge to fetch participants for  	
  # * *Returns* :
  #   - JSON a collection of participants with member__r data
  # * *Raises* :
  #   - ++ ->
  #  	
	def participants
		expose Challenge.participants(@oauth_token, params[:challenge_id].strip)
	end				

  #
  # Returns a collection of comments for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - challenge_id -> the id of the challenge to fetch participants for  	
  # * *Returns* :
  #   - JSON a collection of comments objects with member__r data and
  #   challenge_comments__r for comment replies
  # * *Raises* :
  #   - ++ ->
  #  
	def comments
		expose Challenge.comments(@oauth_token, params[:challenge_id].strip)
	end				

end