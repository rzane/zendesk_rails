require 'spec_helper'

module ZendeskRails
  describe Ticket do
    before { configure(test_mode: true) }

    subject do
      Ticket.new(
        subject: 'Test',
        body: 'Test',
        requester: {
          name: 'Test',
          email: 'Test'
        }
      )
    end

    it_behaves_like 'ActiveModel'

    describe '#valid?' do
      it 'should be valid with subject, body, and requester' do
        expect(subject.valid?).to eq(true)
      end

      it 'should be invalid without subject' do
        allow(subject).to receive(:subject) { nil }
        expect(subject.valid?).to eq(false)
      end

      it 'should be invalid without body' do
        allow(subject).to receive(:body) { nil }
        expect(subject.valid?).to eq(false)
      end

      it 'should be invalid without requester' do
        allow(subject).to receive(:requester) { nil }
        expect(subject.valid?).to eq(false)
      end
    end

    describe '#errors' do
      it 'should set error when missing subject' do
        allow(subject).to receive(:subject).and_return(nil)
        subject.valid?
        expect(subject.errors[:subject]).to eq(["can't be blank"])
      end

      it 'should set error when missing body' do
        allow(subject).to receive(:body).and_return(nil)
        subject.valid?
        expect(subject.errors[:body]).to eq(["can't be blank"])
      end

      it 'should set error when missing requester' do
        allow(subject).to receive(:requester).and_return(nil)
        subject.valid?
        expect(subject.errors[:requester]).to eq(["can't be blank"])
      end

      it 'should set error when missing requester email' do
        allow(subject).to receive(:requester).and_return(name: 'Test')
        subject.valid?
        expect(subject.errors[:email]).to eq(["can't be blank"])
      end

      it 'should set error when missing requester name' do
        allow(subject).to receive(:requester).and_return(email: 'test@example.com')
        subject.valid?
        expect(subject.errors[:name]).to eq(["can't be blank"])
      end
    end

    describe '#create' do
      it 'should call create on the client' do
        expect(ZendeskRails.client).to receive_message_chain(:tickets, :create)
        subject.create
      end

      it 'should merge ticket_create_params from config' do
        configure(test_mode: true, ticket_create_params: { group_id: 111111 })

        expect(subject.client.tickets).to receive(:create).with({
          subject: "Test",
          comment: { value: "Test" },
          group_id: 111111,
          requester: { name: "Test", email: "Test" }
        })

        subject.create
      end

      context 'when valid' do
        it 'should return the ticket' do
          expect(subject.create).to be_a(Testing::Ticket)
        end

        it 'should set the ticket' do
          subject.create
          expect(subject.ticket).to be_a(Testing::Ticket)
        end
      end

      context 'when invalid' do
        before { allow(subject).to receive(:valid?).and_return(false) }

        it 'should return nil' do
          expect(subject.create).to be_nil
        end

        it 'should set the ticket to nil' do
          subject.create
          expect(subject.ticket).to be_nil
        end
      end
    end

    describe '.search' do
      let(:conditions) { Hash.new }

      it 'should convert a query hash to a string' do
        conditions[:query] = { example: 'test' }
        Ticket.search(conditions)
        expect(conditions[:query]).to eq('example:test')
      end

      it 'should not modify the query if it is a string' do
        conditions[:query] = 'example:test'
        Ticket.search(conditions)
        expect(conditions[:query]).to eq('example:test')
      end

      it 'should set sort_by to created_at by default' do
        Ticket.search(conditions)
        expect(conditions[:sort_by]).to eq(:created_at)
      end

      it 'should allow overriding sort_by' do
        configure(test_mode: true, ticket_list_options: { sort_by: :updated_at })
        Ticket.search(conditions)
        expect(conditions[:sort_by]).to eq(:updated_at)
      end

      it 'should set sort_order to desc by default' do
        Ticket.search(conditions)
        expect(conditions[:sort_order]).to eq(:desc)
      end

      it 'should allow overriding sort_order' do
        configure(test_mode: true, ticket_list_options: { sort_order: :asc })
        Ticket.search(conditions)
        expect(conditions[:sort_order]).to eq(:asc)
      end

      it 'should allow providing custom search parameters' do
        configure(test_mode: true, ticket_list_options: { example: true })
        Ticket.search(conditions)
        expect(conditions[:example]).to eq(true)
      end
    end

    describe '.find_request' do
      let(:ticket) { double 'Ticket' }

      it 'should call requests.find on the client' do
        expect(ZendeskRails.client).to receive_message_chain(:requests, :find) { ticket }
        Ticket.find_request(1)
      end

      it 'should call find with the id' do
        configure test_mode: false
        expect_any_instance_of(ZendeskAPI::Collection).to receive(:find).with(id: 1) { ticket }
        Ticket.find_request(1)
      end

      it 'should raise an error when not found' do
        expect(ZendeskRails.client).to receive_message_chain(:requests, :find) { nil }
        expect { Ticket.find_request(1) }.to raise_error(Resource::NotFoundException)
      end
    end

    describe '.find_ticket' do
      let(:ticket) { double 'Ticket' }

      it 'should call tickets.find on the client' do
        expect(ZendeskRails.client).to receive_message_chain(:tickets, :find) { ticket }
        Ticket.find_ticket(1)
      end

      it 'should call find with the id' do
        configure test_mode: false
        expect_any_instance_of(ZendeskAPI::Collection).to receive(:find).with(id: 1) { ticket }
        Ticket.find_ticket(1)
      end

      it 'should raise an error when not found' do
        expect(ZendeskRails.client).to receive_message_chain(:requests, :find) { nil }
        expect { Ticket.find_request(1) }.to raise_error(Resource::NotFoundException)
      end
    end
  end
end
