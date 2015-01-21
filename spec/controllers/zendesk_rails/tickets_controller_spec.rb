require 'spec_helper'

describe ZendeskRails::TicketsController do
  routes { ZendeskRails::Engine.routes }
  render_views

  let(:user) { OpenStruct.new(email: 'user@example.com', name: 'User Example') }

  before do
    configure test_mode: true
    sign_in(user)
  end

  describe 'GET index' do
    it 'should assign @tickets' do
      get :index
      expect(assigns(:tickets)).to eq([])
    end

    it 'should search using current users email' do
      params = { query: { requester: user.email } }
      expect(ZendeskRails::TicketHandler).to receive(:search).with(params).and_return([])
      get :index
    end

    it 'should render the index template' do
      expect(get(:index)).to render_template('zendesk_rails/tickets/index')
    end
  end

  describe 'GET new' do
    it 'should assign @handler' do
      get :new
      expect(assigns(:handler)).to be_instance_of(ZendeskRails::TicketHandler)
    end

    it 'should render the new template' do
      expect(get(:new)).to render_template('zendesk_rails/tickets/new')
    end
  end

  describe 'POST create' do
    describe 'authenticated' do
      let(:params) { { 'ticket' => { 'subject' => 'Test', 'body' => 'Test' } } }

      it 'should assign @hander' do
        post :create, params
        expect(assigns(:handler)).to be_instance_of(ZendeskRails::TicketHandler)
      end

      it 'should assign @ticket' do
        post :create, params
        expect(assigns(:ticket)).not_to be_nil
      end

      it 'should pass the params to ticket handler' do
        attributes = params['ticket'].merge(requester: user.to_h)
        expect(ZendeskRails::TicketHandler).to receive(:new).with(attributes).and_call_original
        post :create, params
      end

      context 'when valid' do
        it 'should redirect to the new ticket' do
          post :create, params
          expect(response).to redirect_to(action: :show, id: assigns(:ticket).id)
        end

        it 'should set the sucess flash' do
          post :create, params
          expect(flash[:success]).to be_present
        end
      end

      context 'when invalid' do
        it 'should render the new template' do
          allow_any_instance_of(ZendeskRails::TicketHandler).to receive(:create).and_return(nil)
          expect(post(:create, params)).to render_template('zendesk_rails/tickets/new')
        end
      end
    end

    describe 'unauthenticated' do
      before { sign_out }

      let(:params) do
        { 'ticket' => { 'subject' => 'Test', 'body' => 'Test', 'name' => 'Test', 'email' => 'Test' } }
      end

      it 'should assign @hander' do
        post :create, params
        expect(assigns(:handler)).to be_instance_of(ZendeskRails::TicketHandler)
      end

      it 'should assign @ticket' do
        post :create, params
        expect(assigns(:ticket)).not_to be_nil
      end

      it 'should pass the params to ticket handler' do
        ticket = params['ticket'].except('name', 'email').merge(requester: { name: 'Test', email: 'Test' })
        expect(ZendeskRails::TicketHandler).to receive(:new).with(ticket).and_call_original
        post :create, params
      end

      context 'when valid' do
        it 'should redirect to the ticket' do
          post :create, params
          expect(response).to redirect_to(action: :show, id: assigns(:ticket).id)
        end
      end

      context 'when invalid' do
        it 'should render the new template' do
          allow_any_instance_of(ZendeskRails::TicketHandler).to receive(:create).and_return(nil)
          expect(post(:create, params)).to render_template('zendesk_rails/tickets/new')
        end
      end
    end
  end

  context 'with existing ticket' do
    before { ZendeskRails::Testing::Ticket.instance_variable_set(:@all, []) }

    let!(:ticket) do
      ZendeskRails::TicketHandler.new(
        subject: 'Test',
        body: 'Test',
        requester: {
          name: 'User Example',
          email: 'user@example.com'
        }
      ).create
    end

    shared_examples 'ticket_assignment' do |block|
      it 'should assign @ticket' do
        instance_exec &block
        expect(assigns(:ticket)).to eq(ticket)
      end
    end

    describe 'GET show' do
      include_examples 'ticket_assignment', ->{ get :show, id: '1' }

      it 'should assign @handler' do
        get :show, id: '1'
        expect(assigns(:handler)).to be_instance_of(ZendeskRails::CommentHandler)
      end

      it 'should call comments on the @handler' do
        expect_any_instance_of(ZendeskRails::CommentHandler).to receive(:comments).and_return([])
        get :show, id: '1'
      end

      it 'should render the show template' do
        expect(get(:show, id: '1')).to render_template('zendesk_rails/tickets/show')
      end
    end

    describe 'PUT update' do
      let(:params) { { id: '1', ticket: { comment: 'test' } } }

      include_examples 'ticket_assignment', ->{ put :update, params }

      it 'should assign @handler' do
        put(:update, params)
        expect(assigns(:handler)).to be_instance_of(ZendeskRails::CommentHandler)
      end

      context 'when valid' do
        it 'should redirect to the ticket' do
          expect(put(:update, params)).to redirect_to(action: :show, id: '1')
        end

        it 'should flash success' do
          put :update, params
          expect(flash[:success]).to be_present
        end
      end

      context 'when invalid' do
        before { allow(ticket).to receive(:save).and_return(false) }

        it 'should re-render the show action' do
          put :update, params
          expect(response).to render_template('zendesk_rails/tickets/show')
        end
      end
    end
  end
end
