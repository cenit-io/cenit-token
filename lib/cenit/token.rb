require 'cenit/token/engine'

module Cenit
  module Token
    extend ActiveSupport::Concern
    extend Cenit::Config

    class << self

      #Inspired by Devise
      def friendly(length)
        SecureRandom.urlsafe_base64((length * 3) / 4).tr('lIO0', 'sxyz')
      end

      def default_options
        {
          collection_name: to_s.collectionize
        }
      end

      delegate :all, :where, :create, to: :basic_token_class

      def basic_token_class
        Cenit::BasicToken
      end
    end

    included do

      include Mongoid::Document
      include Mongoid::Timestamps

      store_in collection: -> { Cenit::Token.collection_name }

      field :token, type: String
      field :token_span, type: Integer, default: -> { self.class.default_token_span }
      field :data

      before_save :ensure_token

    end

    def ensure_token
      self.token = Token.friendly(self.class.token_length) unless token.present?
      true
    end

    def long_term?
      token_span.nil?
    end

    module ClassMethods

      def token_length(*args)
        if (arg = args[0])
          @token_length = arg
        else
          @token_length ||= 20
        end
      end

      def default_token_span(*args)
        if (arg = args[0])
          @token_span = arg.to_i rescue nil
        else
          @token_span
        end
      end

    end
  end
end
