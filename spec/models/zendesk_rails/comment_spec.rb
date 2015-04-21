require 'spec_helper'

module ZendeskRails
  describe Comment do
    before { configure(test_mode: true) }

    let(:ticket) { double('ZendeskAPI::Ticket', requester_id: 1) }
    subject { Comment.new(ticket, comment: 'Test') }

    it_behaves_like 'ActiveModel'

    describe '#valid?' do
      it 'should be valid with a requester_id and comment' do
        expect(subject.valid?).to eq(true)
      end

      it 'should be invalid without comment' do
        allow(subject).to receive(:comment).and_return(nil)
        expect(subject.valid?).to eq(false)
      end

      it 'should be invalid without requester_id' do
        allow(subject).to receive(:requester_id).and_return(nil)
        expect(subject.valid?).to eq(false)
      end
    end

    describe '#errors' do
      it 'should set errors when missing comment' do
        allow(subject).to receive(:comment).and_return(nil)
        subject.valid?
        expect(subject.errors[:comment]).to eq(["can't be blank"])
      end

      it 'should set errors when missing requester_id' do
        allow(subject).to receive(:requester_id).and_return(nil)
        subject.valid?
        expect(subject.errors[:requester_id]).to eq(["can't be blank"])
      end
    end

    describe '#save' do
      context 'when valid' do
        before do
          allow(subject.ticket).to receive(:comment=)
          allow(subject.ticket).to receive(:save).and_return(true)
        end

        it 'should return true' do
          expect(subject.save).to eq(true)
        end

        it 'should set the ticket comment' do
          expect(subject.ticket).to receive(:comment=).with(body: 'Test', author_id: 1)
          subject.save
        end

        it 'should save the ticket' do
          expect(subject.ticket).to receive(:save)
          subject.save
        end
      end

      context 'when invalid' do
        before { allow(subject).to receive(:valid?).and_return(false) }

        it 'should return false' do
          expect(subject.save).to eq(false)
        end

        it 'should not set the comment' do
          expect(subject.ticket).not_to receive(:comment=)
          subject.save
        end

        it 'should not save the ticket' do
          expect(subject.ticket).not_to receive(:save)
          subject.save
        end
      end
    end
  end
end
