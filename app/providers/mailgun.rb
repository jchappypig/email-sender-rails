class Mailgun
  URL = "https://api:#{Figaro.env.mailgun_api_key}@api.mailgun.net/v3/sandbox65ab063cd04f42ecb08990f311580dce.mailgun.org/messages"
  class << self
    def send(from, to, subject, content, cc, bcc)
      payload = {
          from: from,
          to: to,
          cc: cc,
          bcc: bcc,
          subject: subject,
          text: content,
      }

      begin
        response = RestClient::Request.execute(
            method: :post,
            url: URL,
            payload: payload
        )

        response_body = 'Email sent successfully!'
      rescue RestClient::ExceptionWithResponse => err
        response = err.response
        response_body = response.body
      ensure
        return RestClient::Response.create(to_json(response_body), response.net_http_res, response.request)
      end
    end

    private

    def to_json(response_body)
      JSON.parse(response_body)
      return response_body
    rescue JSON::ParserError => e
      return response_body.to_json
    end
  end
end