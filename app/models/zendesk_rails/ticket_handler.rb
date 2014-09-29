require 'active_model'

module ZendeskRails
  class TicketHandler
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_reader :ticket
    attr_accessor :name, :email, :subject, :body, :requester, :comment

    validates :subject, :body, :requester, presence: true
    validate :requester_email_presence, :requester_name_presence

    def initialize(attributes = {})
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    def create
      @ticket = self.class.client.tickets.create(create_params) if valid?
    end

    def create_params
      {
        subject: subject,
        comment: { value: body },
        requester: requester
      }.merge(ZendeskRails.config.ticket_create_params)
    end

    def persisted?
      false
    end

    def requester_email_presence
      if requester && requester[:email].blank?
        errors.add(:email, "can't be blank")
      end
    end

    def requester_name_presence
      if requester && requester[:name].blank?
        errors.add(:name, "can't be blank")
      end
    end

    class << self
      delegate :client, to: ZendeskRails

      def search(conditions = {})
        conditions[:query] = to_query(conditions[:query])
        conditions.merge!(ZendeskRails.config.ticket_list_options)
        client.search(conditions)
      end

      def find_request(id)
        client.requests.find(id: id)
      end

      def find_ticket(id)
        client.tickets.find(id: id)
      end

      private

      def to_query(query)
        return query unless query.respond_to?(:keys)
        query.to_a.map { |a| a.join(':') }.join('+')
      end
    end
  end
end
