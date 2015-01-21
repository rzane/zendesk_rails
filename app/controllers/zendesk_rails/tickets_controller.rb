module ZendeskRails
  class TicketsController < ApplicationController
    layout :zendesk_layout

    def index
      @tickets = TicketHandler.search(query: {
        requester: zendesk_user_attribute(:email)
      })
    end

    def show
      @ticket  = TicketHandler.find_request(params[:id])
      @handler = CommentHandler.new(@ticket)
    end

    def new
      @handler = TicketHandler.new
    end

    def create
      @handler = TicketHandler.new(ticket_params)

      if @ticket = @handler.create
        flash_key = zendesk_user_signed_in? ? :authenticated : :unauthenticated
        redirect_to after_zendesk_ticket_created_path_for(@ticket), flash: {
          success: t("zendesk.tickets.create.#{flash_key}.message")
        }
      else
        render *Array(after_zendesk_ticket_invalid_template)
      end
    end

    def update
      @ticket  = TicketHandler.find_ticket(params[:id])
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
        name: (params[:ticket][:name].presence || zendesk_user_attribute(:name)),
        email: (params[:ticket][:email].presence || zendesk_user_attribute(:email))
      })
    end
  end
end
