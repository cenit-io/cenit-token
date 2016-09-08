module Cenit
  module Token
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :exception
    end
  end
end
