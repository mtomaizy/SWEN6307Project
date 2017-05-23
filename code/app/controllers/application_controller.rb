class ApplicationController < ActionController::Base
 # protect_from_forgery with: :exception
  after_action :set_version_header

  protected
    def set_version_header
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end
end
