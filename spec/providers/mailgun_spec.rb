require 'rails_helper'

RSpec.describe Mailgun, type: :provider do
  describe 'send' do
    def new_response(body, net_http_res, request)
      OpenStruct.new(body: body, net_http_res: net_http_res, request: request, code: net_http_res.code)
    end

    before(:each) do
      allow(Figaro).to receive(:env).and_return(OpenStruct.new(mailgun_api_key: 'abc_mailgun_key'))
      allow(RestClient::Response).to receive(:create) do |body, net_http_res, request|
        new_response(body, net_http_res, request)
      end
    end

    it('calls Mailgun API') do
      success_response = new_response('', OpenStruct.new({code: 202}), 'request')
      allow(RestClient::Request).to receive(:execute)
      .and_return(success_response)
      expect(RestClient::Request).to receive(:execute).with({
        method: :post,
        url: Mailgun::URL,
        payload: {
          from: 'jchappypig@hotmail.com',
          to: 'to@hotmail.com, happy <hh@gmail.com>',
          subject: 'hello subject',
          text: 'hello world content',
          cc: nil,
          bcc: 'Huanhuan <jchappypig@gmail.com>'
        }
      })

      Mailgun.send(
        'jchappypig@hotmail.com',
        'to@hotmail.com, happy <hh@gmail.com>',
        'hello subject',
        'hello world content',
        nil,
        'Huanhuan <jchappypig@gmail.com>'
      )
    end

    it('returns constructed response on success') do
      success_response = new_response('', OpenStruct.new({code: 202}), 'request')
      allow(RestClient::Request).to receive(:execute).and_return(success_response)

      response = Mailgun.send(
        'jchappypig@hotmail.com',
        'to@hotmail.com, happy <hh@gmail.com>',
        'hello subject',
        'hello world content',
        'Stephano <stephano@gmail.com>',
        'Huanhuan <jchappypig@gmail.com>'
      )

      expect(response.code).to eq(202)
      expect(response.body).to eq("\"Email sent successfully!\"")
    end

    it('returns constructed response on error') do
      error_response = RestClient::ExceptionWithResponse.new(
        new_response('{"errors": "invalid"}', OpenStruct.new({code: 400}), 'request')
      )
      allow(RestClient::Request).to receive(:execute)
        .and_raise(error_response)

      response = Mailgun.send(
        'jchappypig@hotmail.com',
        'to@hotmail.com, happy <hh@gmail.com>',
        'hello subject',
        'hello world content',
        'Stephano <stephano@gmail.com>',
        'Huanhuan <jchappypig@gmail.com>'
      )

      expect(response.code).to eq(400)
      expect(response.body).to eq("{\"errors\": \"invalid\"}")
    end
  end
end