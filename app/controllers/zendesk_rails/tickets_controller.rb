require_dependency 'zendesk_rails/application_controller'

module ZendeskRails
  class TicketsController < ApplicationController
    def index
      @tickets = client.search(
        query: "requester:#{zendesk_user_attribute(:email)}",
        sort_by: 'created_at',
        sort_order: 'desc'
      )
    end

    def show
      @ticket = client.requests.find(id: params[:id])
      @comments = @ticket.comments(
        sort_by: 'created_at',
        sort_order: 'desc'
      )
    end

    def new
    end

    def create
      @ticket = create_ticket
    end

    def update
      @ticket = client.tickets.find(id: params[:id])
      @ticket.comment = {
        body: params[:comment],
        author_id: @ticket.requester_id
      }

      redirect_to ticket_path(@ticket.id), flash: { success: t('zendesk.comments.added') }
    end

    private

    def create_ticket
      client.tickets.create(
        subject: params[:subject],
        comment: { value: params[:body] },
        requester: {
          name: zendesk_user_attribute(:name),
          email: zendesk_user_attribute(:email)
        }
      )
    end

    def client
      ZendeskRails.client
    end
  end
end
