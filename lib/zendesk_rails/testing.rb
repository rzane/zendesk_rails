module ZendeskRails
  module Testing
    class Resource
      def initialize(attributes)
        @attributes = attributes.symbolize_keys
      end

      def method_missing(method, *args, &block)
        if attribute = @attributes[method]
          attribute.respond_to?(:keys) ? OpenStruct.new(attribute) : attribute
        else
          super
        end
      end

      class << self
        def all
          (@all ||= []).sort { |a, b| b.created_at <=> a.created_at }
        end

        delegate *Array.instance_methods(false), to: :all
      end
    end

    class Comment < Resource
      def initialize(attributes)
        attributes.reverse_merge!(
          created_at: Time.now,
          updated_at: Time.now
        )
        super(attributes)
      end
    end

    class Ticket < Resource
      def initialize(attributes)
        attributes.reverse_merge!(
          created_at: Time.now,
          updated_at: Time.now,
          priority: 'low',
          status: 'new',
          comments: []
        )
        super(attributes)
      end

      def save
        true
      end

      def requester_id
        @requester_id ||= rand(1..1000)
      end

      def as_comment
        @attributes.slice(:created_at, :updated_at).merge(
          html_body: description,
          author: { name: requester[:name] }
        )
      end

      def comments(_opts = {})
        list = (@attributes[:comments] + [as_comment]).map { |c| Comment.new(c) }
        list.sort { |a, b| b.created_at <=> a.created_at }
      end

      def comment=(opts)
        @attributes[:comments].unshift(
          html_body: opts[:body],
          author: requester
        )
      end

      class << self
        def create(client_or_opts = {}, opts = nil)
          opts ||= client_or_opts
          id = (all.map(&:id).max || 0) + 1
          opts.merge!(id: id, description: opts[:comment][:value])
          ticket = new opts.slice(:subject, :requester, :description, :id)
          @all.unshift ticket
          ticket
        end

        def find(opts = {})
          all.find do |ticket|
            opts.map do |key, value|
              ticket.send(key) == value || ticket.send(key).to_s == value
            end.all?
          end
        end
      end
    end

    class Client
      def tickets(_opts = {})
        Ticket
      end
      alias_method :requests, :tickets
      alias_method :search, :tickets
    end
  end
end
