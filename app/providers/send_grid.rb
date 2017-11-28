class SendGrid
  URL = 'https://api.sendgrid.com/v3/mail/send'
  class << self
    def send(from, to, subject, content, cc, bcc)
      personalizations = [{
                            to: to && mapToEmails(to),
                            cc: cc && mapToEmails(cc),
                            bcc: bcc && mapToEmails(bcc),
                          }]

      payload = {
        personalizations: personalizations,
        from: from && mapToEmails(from)[0],
        subject: subject,
        content: [mapToContent(content)]
      }
      begin
        response = RestClient::Request.execute(
          method: :post,
          url: URL,
          payload: payload.to_json,
          headers:
            {
              Authorization: "Bearer #{Figaro.env.send_grid_api_key}",
              content_type: :json
            }
        )
        response_body = 'Email sent successfully!'
      rescue RestClient::ExceptionWithResponse => err
        response = err.response
        response_body = response.body
      ensure
        return RestClient::Response.create(to_json(response_body), response.net_http_res, response.request)
      end
    end

    def mapToEmails(input)
      if (!input)
        return;
      end

      input
        .split(',')
        .map {|email| email.strip}
        .select {|email| email.present?}
        .map {|email| extractEmail(email)}
    end

    def mapToContent(input)
      {
        type: 'text/plain',
        value: input
      }
    end

    private

    def to_json(response_body)
      # Because SendGrid returns a different response format with Mailgun.
      # Here is to consistent them with return format [{message: 'error message'}]
      (JSON.parse(response_body)['errors']).to_json
    rescue JSON::ParserError => e
      response_body.to_json
    end

    def extractEmail(input)
      email = input
      email_with_name_regex = /(.+)?<(.+)>$/;
      matches = email_with_name_regex.match(input)

      if (matches)
        email = matches[2].to_s.strip
        name = matches[1].to_s.strip
      end

      if (name && name.present?)
        return {email: email, name: name}
      end

      {email: email}
    end
  end
end