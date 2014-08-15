require 'spec_helper'

describe ZendeskRails::CommentHandler do
  before { configure(test_mode: true) }

  let(:ticket) { double('ZendeskAPI::Ticket', requester_id: 1) }
  subject { ZendeskRails::CommentHandler.new(ticket, comment: 'Test') }

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

  describe '#comments' do
    let(:conditions) { ZendeskRails::Configuration::DEFAULT_SORTING.dup }

    it 'should be called with the default sorting options' do
      expect(ticket).to receive(:comments).with(conditions)
      subject.comments
    end

    it 'should allow overriding sort_by' do
      configure(test_mode: true, comment_list_options: { sort_by: :updated_at })
      conditions[:sort_by] = :updated_at
      expect(ticket).to receive(:comments).with(conditions)
      subject.comments
    end

    it 'should allow overriding sort_order' do
      configure(test_mode: true, comment_list_options: { sort_order: :asc })
      conditions[:sort_order] = :asc
      expect(ticket).to receive(:comments).with(conditions)
      subject.comments
    end

    it 'should allow custom parameters' do
      configure(test_mode: true, comment_list_options: { example: true })
      conditions[:example] = true
      expect(ticket).to receive(:comments).with(conditions)
      subject.comments
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
