class Mailgun
	URL = 'https://api.sendgrid.com/v3/mail/send'
	class << self
		def send(from, to, subject, content, cc, bcc)
			# personalizations = [{
			# 	to: to && mapToEmails(to),
			# 	cc: cc && mapToEmails(cc),
			# 	bcc: bcc && mapToEmails(bcc),
			# }]

			# payload = {
			# 	personalizations: personalizations,
			# 	from: from && mapToEmails(from)[0],
			# 	subject: subject,
			# 	content: [ mapToContent(content) ]
			# }
			# begin
			# 	response = RestClient::Request.execute(
			# 		method: :post,
			# 		url: URL,
			# 		payload: payload.to_json,
			# 		headers:
			# 			{
			# 				Authorization: "Bearer #{Figaro.env.send_grid_api_key}",
			# 				content_type: :json
			# 			}
			# 	)

			# 	return {code: response.code, body: 'Email sent successfully!'}
			# rescue RestClient::ExceptionWithResponse => err
			# 	response = err.response
			# 	return {code: response.code, body: JSON.parse(response.body)}
			# end
		end
	end
end