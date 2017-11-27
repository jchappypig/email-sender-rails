require 'rails_helper'

RSpec.describe EmailsService, type: :service do
  let(:from) { 'from@hello.com' }
  let(:to) { 'to@hello.com' }
  let(:cc) { 'cc@hello.com' }
  let(:bcc) { 'bcc@hello.com' }
  let(:subject) { 'This is a subject' }
  let(:content) { 'This is a content' }

  it 'calls SendGrid provider' do
    allow(SendGrid).to receive(:send)
    expect(SendGrid).to receive(:send).with(from, to, subject, content, cc, bcc)

    EmailsService.send(from, to, subject, content, cc, bcc)
  end

  it 'has cc and bcc as optional params' do
    allow(SendGrid).to receive(:send)
    expect(SendGrid).to receive(:send).with(from, to, subject, content, nil, nil)

    EmailsService.send(from, to, subject, content)
  end
end