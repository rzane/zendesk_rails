require 'active_model'

module ZendeskRails
  class Resource
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    class NotFoundException < StandardError
      attr_reader :id, :resource

      def initialize(id, resource)
        @id, @resource = id, resource
      end

      def to_s
        "#{resource} ##{id} not found."
      end
    end

    class << self
      delegate :client, :config, to: :ZendeskRails
      attr_reader :known_fields

      def has_fields(*names)
        @known_fields ||= []
        @known_fields |= names.map(&:to_s)
      end

      def resource_not_found!(id)
        fail NotFoundException.new(id, self)
      end
    end
    delegate :known_fields, :client, :config, to: :class

    attr_accessor :attributes

    def initialize(attributes = {})
      @attributes = attributes.with_indifferent_access
    end

    def persisted?
      false
    end

    def respond_to_missing?(meth, *)
      known_fields.include?(meth.to_s) || super
    end

    def method_missing(meth, *args, &block)
      if attributes.key?(meth)
        attributes[meth]
      elsif known_fields.include?(meth.to_s)
        nil
      else
        super
      end
    end
  end
end
