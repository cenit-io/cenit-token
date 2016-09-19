module Cenit
  module TenantToken
    extend ActiveSupport::Concern

    include Token

    class << self

      delegate :all, :where, :create, to: :basic_tenant_token_class

      def basic_tenant_token_class
        Cenit::BasicTenantToken
      end
    end

    included do
      belongs_to :tenant, class_name: Cenit::MultiTenancy.tenant_model_name, inverse_of: nil

      before_create do
        self.tenant = Cenit::MultiTenancy.tenant_model.current_tenant
      end
    end

    def set_current_tenant!
      set_current_tenant(force: true)
    end

    def set_current_tenant(options = {})
      if Cenit::MultiTenancy.tenant_model.current.nil? || options[:force]
        Cenit::MultiTenancy.tenant_model.current = tenant
      end
      tenant
    end
  end
end