module ZendeskRails
  # ActiveModel wrapper for submitting tickets to Zendesk
  class Ticket < Resource
    attr_reader :ticket
    has_fields :name, :email, :subject, :body, :requester
    validates :subject, :body, :requester, presence: true
    validate :requester_email_presence, :requester_name_presence

    # Returns ticket from Zendesk's API, not a ZendeskRails::Ticket
    def create
      return unless valid?
      @ticket = client.tickets.create({
        subject: subject,
        comment: { value: body },
        requester: requester
      }.merge(config.ticket_create_params))
    end

    private

    [:name, :email].each do |key|
      define_method "requester_#{key}_presence" do
        if requester && requester[key].blank?
          errors.add key, "can't be blank"
        end
      end
    end

    class << self
      def search(conditions = {})
        conditions[:query] = to_query(conditions[:query])
        conditions.merge!(config.ticket_list_options)
        client.search conditions
      end

      def belonging_to(email)
        search query: { requester: email }
      end

      def find_request(id)
        client.requests.find(id: id) || resource_not_found!(id)
      end

      def find_ticket(id)
        client.tickets.find(id: id) || resource_not_found!(id)
      end

      private

      def to_query(query)
        return query unless query.respond_to?(:keys)
        query.to_a.map { |a| a.join(':') }.join('+')
      end
    end
  end
end
