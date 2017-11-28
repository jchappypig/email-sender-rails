class EmailsService
  class << self
    def send(from, to, subject, content, cc, bcc)
      send_grid_response = SendGrid.send(from, to, subject, content, cc, bcc)

      status_code = send_grid_response.code
      if (status_code == 400 || (status_code >= 200 && status_code < 300))
        return send_grid_response
      end

      Mailgun.send(from, to, subject, content, cc, bcc)
    end
  end
end