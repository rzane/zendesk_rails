module ZendeskRails
  class TicketsController < ApplicationController
    delegate :config, to: :ZendeskRails, prefix: :zendesk
    delegate :layout, to: :zendesk_config, prefix: :zendesk

    layout :zendesk_layout

    helper_method :zendesk_config,
                  :zendesk_current_user,
                  :zendesk_user_signed_in?,
                  :zendesk_user_attribute

    rescue_from Resource::NotFoundException do |ex|
      redirect_to tickets_path, flash: { alert: t('zendesk.tickets.not_found') }
    end

    def index
      email = zendesk_user_attribute(:email)
      @tickets = Ticket.belonging_to(email)
    end

    def show
      @ticket  = Ticket.find_request(params[:id])
      @comment = Comment.new(@ticket)
      @comments = @ticket.comments(zendesk_config.comment_list_options)
    end

    def new
      @handler = Ticket.new
    end

    def create
      @handler = Ticket.new(ticket_params)

      if @ticket = @handler.create
        after_created_ticket @ticket
      else
        render 'new'
      end
    end

    def update
      @ticket  = Ticket.find_ticket(params[:id])
      @comment = Comment.new(@ticket, comment_params)

      if @comment.save
        after_updated_ticket @ticket
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

    def zendesk_current_user
      send "current_#{zendesk_config.devise_scope}"
    end

    def zendesk_user_signed_in?
      send "#{zendesk_config.devise_scope}_signed_in?"
    end

    # Gets the value of a user's name/emails based on
    # configurable attribute names
    def zendesk_user_attribute(attribute)
      attr_name = zendesk_config.user_attributes[attribute]
      zendesk_current_user.try(attr_name)
    end

    def after_created_ticket ticket
      if zendesk_user_signed_in?
        message = t "zendesk.tickets.create.authenticated.message"
        redirect_to ticket_path(ticket.id), flash: { notice: message }
      else
        render 'create'
      end
    end

    def after_updated_ticket ticket
      message = t 'zendesk.comments.added'
      redirect_to ticket_path(ticket.id), flash: { notice: message }
    end
  end
end
