module ZendeskRails
  class CommentHandler
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_reader :ticket
    attr_accessor :comment, :requester_id

    validates_presence_of :comment, :requester_id

    def initialize(ticket, attributes = {})
      @ticket = ticket
      @requester_id = ticket.requester_id

      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    def save
      return false unless valid?

      ticket.comment = {
        body: comment,
        author_id: ticket.requester_id
      }

      ticket.save
    end

    def comments
      @comments ||= ticket.comments(ZendeskRails.config.comment_list_options)
    end

    def persisted?
      false
    end
  end
end
