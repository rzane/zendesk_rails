require_dependency 'zendesk_rails/application_controller'

module ZendeskRails
  class TicketsController < ApplicationController
    def index
      @tickets = TicketHandler.search(query: {
        requester: zendesk_user_attribute(:email)
      })
    end

    def show
      @ticket = TicketHandler.find_request(params[:id])
      @handler = CommentHandler.new(@ticket)
    end

    def new
      @handler = TicketHandler.new
    end

    def create
      @handler = TicketHandler.new(ticket_params)

      if @ticket = @handler.create
        redirect_to ticket_path(@ticket.id), flash: {
          success: t('zendesk.tickets.create.message')
        }
      else
        render 'new'
      end
    end

    def update
      @ticket = TicketHandler.find_ticket(params[:id])
      @handler = CommentHandler.new(@ticket, comment_params)

      if @handler.save
        redirect_to ticket_path(@ticket.id), flash: {
          success: t('zendesk.comments.added')
        }
      else
        render 'show'
      end
    end

    private

    def comment_params
      params.require(:ticket).permit(:comment)
    end

    def ticket_params
      params.require(:ticket).permit(:subject, :body).merge(requester: {
        name: zendesk_user_attribute(:name),
        email: zendesk_user_attribute(:email)
      })
    end
  end
end
