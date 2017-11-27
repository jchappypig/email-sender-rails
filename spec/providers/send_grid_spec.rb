require 'rails_helper'

RSpec.describe SendGrid, type: :provider do
  describe 'mapToEmail' do
    it('returns undefined if input is undefined') do
      expect(SendGrid.mapToEmails(nil)).to eq(nil);
    end

    it('maps email string value to personalization objects') do
      expect(SendGrid.mapToEmails('jchappypig@email.com')).to eq([
        { email: 'jchappypig@email.com' }
      ]);
    end

    it('trims email') do
      expect(SendGrid.mapToEmails('jchappypig@email.com ')).to eq([
        { email: 'jchappypig@email.com' }
      ]);

      expect(SendGrid.mapToEmails(' jchappypig@email.com ')).to eq([
        { email: 'jchappypig@email.com' }
      ]);
    end

    it('can gets multiple emails') do
      expect(SendGrid.mapToEmails('Huanhuan <jchappypig@email.com> , hello@email.com')).to eq([
        {
          email: 'jchappypig@email.com',
          name: 'Huanhuan'
        },
        { email: 'hello@email.com' }
      ]);
    end

    it('ignore empty email address') do
      expect(SendGrid.mapToEmails(' jchappypig@email.com ,')).to eq([
        { email: 'jchappypig@email.com' }
      ]);
    end

    it('understands email with <>') do
      expect(SendGrid.mapToEmails('<jchappypig@email.com>')).to eq([
        { email: 'jchappypig@email.com' }
      ]);

      expect(SendGrid.mapToEmails('< jchappypig@email.com>')).to eq([
        { email: 'jchappypig@email.com' }
      ]);

      expect(SendGrid.mapToEmails('< jchappypig@email.com >')).to eq([
        { email: 'jchappypig@email.com' }
      ]);
    end

    it('understands email with name') do
      expect(SendGrid.mapToEmails('Happy Huang<jchappypig@email.com>')).to eq([
        {
          email: 'jchappypig@email.com',
          name: 'Happy Huang'
        }
      ]);

      expect(SendGrid.mapToEmails('Huan< jchappypig@email.com>')).to eq([
        {
          email: 'jchappypig@email.com',
          name: 'Huan'
        }
      ]);

      expect(SendGrid.mapToEmails(' Huanhuan Huang  < jchappypig@email.com >')).to eq([
        {
          email: 'jchappypig@email.com',
          name: 'Huanhuan Huang'
        }
      ]);
    end
  end

  describe 'mapToContent' do
    it('returns content with type') do
      expect(SendGrid.mapToContent('my content')).to eq({type: 'text/plain', value: 'my content'})
    end
  end

  describe 'send' do
    before(:each) do
      allow(Figaro).to receive(:env).and_return(OpenStruct.new(send_grid_api_key: 'abc_sengrid_key'))
    end

    it('calls sendgrid API') do
      allow(RestClient::Request).to receive(:execute)
      expect(RestClient::Request).to receive(:execute).with({
        method: :post,
        url: SendGrid::URL,
        payload: {
          personalizations: [{
            to: [
              {
                email: 'to@hotmail.com'
              },
              {
                email: 'hh@gmail.com',
                name: 'happy'
              }
            ],
            cc: nil,
            bcc: [{
              email: 'jchappypig@gmail.com',
              name: 'Huanhuan'
            }]
          }],
          from: {
            email: 'jchappypig@hotmail.com'
          },
          subject: 'hello subject',
          content: [{
            type: 'text/plain',
            value: 'hello world content'
          }]
        }.to_json,
        headers:
          {
            Authorization: 'Bearer abc_sengrid_key',
            content_type: :json
          }
      })

      SendGrid.send(
        'jchappypig@hotmail.com',
        'to@hotmail.com, happy <hh@gmail.com>',
        'hello subject',
        'hello world content',
        nil,
        'Huanhuan <jchappypig@gmail.com>'
      )
    end
  end
end