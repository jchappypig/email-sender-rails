require 'rails_helper'

RSpec.describe EmailsController, type: :controller do
  let(:email_params) {{ 
    'from' => 'from@test.com',
    'to' => 'to@test.com',
    'subject' => 'email subject',
    'content' => 'email content',
    'cc' => 'cc@test.com',
    'bcc' => 'bcc@test.com',
  }}
  
  describe 'POST #create' do
    it 'calls email service' do
      service_response = OpenStruct.new(code: 202)
      allow(EmailsService).to receive(:send).and_return(service_response)
      expect(EmailsService).to receive(:send).with(
        email_params['from'],
        email_params['to'],
        email_params['subject'],
        email_params['content'],
        email_params['cc'],
        email_params['bcc'],
      )
      post :create, params: email_params
    end

    it 'returns 202 as EmailService' do
      service_response = OpenStruct.new(code: 202)
      allow(EmailsService).to receive(:send).and_return(service_response)

      post :create, params: email_params

      expect(response.status).to eq(202)
    end

    it 'returns 400 as EmailService' do
      service_response = OpenStruct.new(code: 400, errors: 'bad request')
      allow(EmailsService).to receive(:send).and_return(service_response)

      post :create, params: email_params

      expect(response.status).to eq(400)
    end
  end
end
