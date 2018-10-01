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
      field :data
      field :expires_at, type: Time

      after_initialize do
        self.token_span ||= attributes.delete('token_span') ||
          if created_at
            expires_at && (expires_at - created_at)
          else
            self.class.default_token_span
          end
      end

      def set_created_at
        r = super
        self.expires_at = token_span && (created_at + token_span)
        r
      end

      before_save :ensure_token
    end

    def token_span=(span)
      span = span && span.abs
      self.expires_at =
        if (@token_span = span)
          created_at && (created_at + span)
        else
          nil
        end
    end

    def token_span
      @token_span
    end

    def ensure_token
      self.token = Token.friendly(self.class.token_length) unless token.present?
      true
    end

    def long_term?
      token_span.nil?
    end

    def alive?
      expires_at.nil? || Time.now < expires_at
    end

    def expired?
      !alive?
    end

    module ClassMethods

      def token_length(*args)
        if (arg = args[0])
          @token_length = arg
        else
          @token_length || (superclass < Cenit::Token ? superclass.token_length : 20)
        end
      end

      def default_token_span(*args)
        if (arg = args[0])
          @token_span = arg.to_i rescue nil
        else
          @token_span || (superclass < Cenit::Token ? superclass.default_token_span : nil)
        end
      end

    end
  end
end
