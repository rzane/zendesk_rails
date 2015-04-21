module ZendeskRails
  class Comment < Resource
    attr_reader :ticket
    has_fields :comment
    delegate :requester_id, to: :ticket
    validates_presence_of :comment, :requester_id

    def initialize(ticket, attributes = {})
      @ticket = ticket
      super(attributes)
    end

    def save
      return false unless valid?
      ticket.comment = { body: comment, author_id: requester_id }
      ticket.save
    end
  end
end
