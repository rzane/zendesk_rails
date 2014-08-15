require 'spec_helper'

describe ZendeskRails do
  describe '.configure' do
    let(:url) { 'https://example.zendesk.com/api/v2' }
    let(:username) { 'user@example.com' }
    let(:password) { 'secret' }

    it 'should return a client' do
      client = ZendeskRails.configure { |c| c.url = url }
      expect(client).to be_a(ZendeskAPI::Client)
    end

    it 'should set the client from the configure method' do
      ZendeskRails.configure { |c| c.url = url }
      expect(subject.client).to be_a(ZendeskAPI::Client)
    end

    describe 'client configuration' do
      let(:api_config) { subject.client.config }

      it 'should set the url' do
        ZendeskRails.configure { |c| c.url = url }
        expect(api_config.url).to eq(url)
      end

      it 'should set the username' do
        ZendeskRails.configure do |c|
          c.url = url
          c.username = username
        end
        expect(api_config.username).to eq(username)
      end

      it 'should set the password' do
        ZendeskRails.configure do |c|
          c.url = url
          c.password = password
        end
        expect(api_config.password).to eq(password)
      end

      it 'should not set client_options to nil' do
        ZendeskRails.configure { |c| c.url = url }
        expect(api_config.client_options).to eq({})
      end
    end
  end
end
