require 'rails_helper'

RSpec.describe EmailsService, type: :service do
  let(:from) { 'from@hello.com' }
  let(:to) { 'to@hello.com' }
  let(:cc) { 'cc@hello.com' }
  let(:bcc) { 'bcc@hello.com' }
  let(:subject) { 'This is a subject' }
  let(:content) { 'This is a content' }
  let(:send_grid_response) {OpenStruct.new(code: 200, body: "I have SendGrid #{status_code}")}
  let(:mailgun_response) {OpenStruct.new(code: status_code, body: "I have Mailgun #{status_code}")}

  it 'sends email through SsendGrid provider' do
    allow(SendGrid).to receive(:send).and_return(OpenStruct.new(code: 200, body: "I have SendGrid 200}"))
    expect(SendGrid).to receive(:send).with(from, to, subject, content, cc, bcc)

    EmailsService.send(from, to, subject, content, cc, bcc)
  end

  [400, 200, 202].each do |status_code|
    context "when SendGrid returns #{status_code}" do
      let(:send_grid_response) {OpenStruct.new(code: status_code, body: "I have SendGrid #{status_code}")}
      let(:mailgun_response) {OpenStruct.new(code: 401, body: "I have Mailgun 401")}
      
      before(:each) do
        allow(Mailgun).to receive(:send).and_return(mailgun_response)
        allow(SendGrid).to receive(:send).and_return(send_grid_response)
      end

      it 'returns sendgrids response' do
        response = EmailsService.send(from, to, subject, content, cc, bcc)

        expect(response).to eq(send_grid_response)
      end

      it 'does not send email through mailgun' do
        EmailsService.send(from, to, subject, content, cc, bcc)

        expect(Mailgun).not_to receive(:send)
      end
    end
  end

  [429, 401, 500].each do |status_code|
    let(:send_grid_response) {OpenStruct.new(code: status_code, body: "I have SendGrid #{status_code}")}
    let(:mailgun_response) {OpenStruct.new(code: 200, body: "I have Mailgun 200")}
    
    before(:each) do
      allow(SendGrid).to receive(:send).and_return(send_grid_response)
      allow(Mailgun).to receive(:send).and_return(mailgun_response)
    end

    context "when SendGrid returns #{status_code}" do
      it 'fallbacks to mailgun provider' do
        EmailsService.send(from, to, subject, content, cc, bcc)

        expect(Mailgun).to receive(:send)
      end

      it 'returns mailgun response' do
        response = EmailsService.send(from, to, subject, content, cc, bcc)

        expect(response).to eq(mailgun_response)
      end
    end
  end
end