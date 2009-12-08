# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_investor_session',
  :secret      => '518bf1612d035f8ee76175e2656bfc1da026129c8782bf1c5c986305ee9b6de26968c61e50bd457defd7ee8bf9b927176f00005aac096f78a76ee36bacec0361'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
