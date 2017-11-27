class EmailsController < ApplicationController
  def create
    from = email_params['from']
    to = email_params['to']
    cc = email_params['cc']
    bcc = email_params['bcc']
    subject = email_params['subject']
    content = email_params['content']
  
    response = EmailsService.send(from, to, subject, content, cc, bcc)
  
    render status: response.code, json: response
  end
  
  private

  def email_params
    params.permit(:from, :to, :cc, :bcc, :subject, :content)
  end
end
