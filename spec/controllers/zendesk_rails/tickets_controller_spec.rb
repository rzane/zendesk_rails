require 'spec_helper'

module ZendeskRails
  describe TicketsController do
    routes { ZendeskRails::Engine.routes }
    render_views

    let(:user_attrs) do
      {email: 'user@example.com', name: 'User Example'}
    end

    let(:user) { double('User', user_attrs) }

    before do
      Testing::Ticket.clear!
      configure test_mode: true
      sign_in user
    end

    describe 'GET index' do
      it 'should assign @tickets' do
        get :index
        expect(assigns(:tickets)).to eq([])
      end

      it 'should search using current users email' do
        expect(Ticket).to receive(:belonging_to).with(user.email).and_return([])
        get :index
      end

      it 'should render the index template' do
        expect(get(:index)).to render_template('zendesk_rails/tickets/index')
      end
    end

    describe 'GET new' do
      it 'should assign @handler' do
        get :new
        expect(assigns(:handler)).to be_instance_of(Ticket)
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
          expect(assigns(:handler)).to be_instance_of(Ticket)
        end

        it 'should assign @ticket' do
          post :create, params
          expect(assigns(:ticket)).not_to be_nil
        end

        it 'should pass the params to ticket handler' do
          attributes = params['ticket'].merge(requester: user_attrs)
          expect(Ticket).to receive(:new).with(attributes).and_call_original
          post :create, params
        end

        context 'when valid' do
          it 'should redirect to the new ticket' do
            post :create, params
            expect(response).to redirect_to(action: :show, id: assigns(:ticket).id)
          end

          it 'should set the sucess flash' do
            post :create, params
            expect(flash[:notice]).to be_present
          end
        end

        context 'when invalid' do
          it 'should render the new template' do
            allow_any_instance_of(Ticket).to receive(:create).and_return(nil)
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
          expect(assigns(:handler)).to be_instance_of(Ticket)
        end

        it 'should assign @ticket' do
          post :create, params
          expect(assigns(:ticket)).not_to be_nil
        end

        it 'should pass the params to ticket handler' do
          ticket = params['ticket'].except('name', 'email').merge(requester: { name: 'Test', email: 'Test' })
          expect(Ticket).to receive(:new).with(ticket).and_call_original
          post :create, params
        end

        context 'when valid' do
          it 'should show the ticket' do
            post :create, params
            expect(response).to render_template 'create'
          end
        end

        context 'when invalid' do
          it 'should render the new template' do
            allow_any_instance_of(Ticket).to receive(:create).and_return(nil)
            expect(post(:create, params)).to render_template('zendesk_rails/tickets/new')
          end
        end
      end
    end

    context 'with existing ticket' do
      let!(:ticket) do
        double('Ticket', {
          id: 1,
          subject: 'blergh',
          status: 'Open',
          requester_id: 1,
          comments: []
        })
      end

      before do
        allow(Ticket).to receive(:find_request).and_return(ticket)
        allow(Ticket).to receive(:find_ticket).and_return(ticket)
      end

      shared_examples 'ticket_assignment' do |block|
        it 'should assign @ticket' do
          instance_exec &block
          expect(assigns(:ticket)).to eq(ticket)
        end
      end

      describe 'GET show' do
        include_examples 'ticket_assignment', ->{ get :show, id: '1' }

        it 'should assign @ticket' do
          get :show, id: '1'
          expect(assigns(:ticket)).to eq(ticket)
        end

        it 'should assign @comment' do
          get :show, id: '1'
          expect(assigns(:comment)).to be_instance_of(Comment)
        end

        it 'should fetch comments for the @ticket' do
          expect(ticket).to receive(:comments).with({
            sort_by: :created_at,
            sort_order: :desc
          }).and_return([])

          get :show, id: '1'
        end

        it 'should render the show template' do
          get :show, id: '1'
          expect(response).to render_template('zendesk_rails/tickets/show')
        end
      end

      describe 'PUT update' do
        before do
          allow(ticket).to receive(:comment=)
          allow(ticket).to receive(:save).and_return(true)
        end

        let(:params) { { id: '1', ticket: { comment: 'test' } } }

        include_examples 'ticket_assignment', ->{ put :update, params }

        it 'should assign @comment' do
          put(:update, params)
          expect(assigns(:comment)).to be_instance_of(Comment)
        end

        context 'when valid' do
          it 'should redirect to the ticket' do
            expect(put(:update, params)).to redirect_to(action: :show, id: '1')
          end

          it 'should flash notice' do
            put :update, params
            expect(flash[:notice]).to be_present
          end
        end

        context 'when invalid' do
          it 'should re-render the show action' do
            allow(ticket).to receive(:save).and_return(false)
            put :update, params
            expect(response).to render_template('zendesk_rails/tickets/show')
          end
        end
      end
    end
  end
end
