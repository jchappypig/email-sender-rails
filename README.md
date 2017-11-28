## Email sender
A backend service that accepts necessary information and send emails

## Setup
You will need to config SendGrid and Mailgun API key before starting the service.
Create `config/application.yml` and put your API keys there.

eg.
```
send_grid_api_key: 'sendgridabcdefg'
mailgun_api_key: 'mailgnabcdefg'
```

## How to run the service
```
rails s
```

Server will be started at [http://localhost:3000](http://localhost:3000)

Once you setup, try this 👇:

```
curl --request POST --url 'http://localhost:3000/emails' --data "from='jchappypig@hotmail.com&to='jchappypig@hotmail.com,jchappypig@gmail.com'&subject='Hi'&content='How is your weekend?'"
```

## How to run the tests

```
bundle exec spec
```

## App structure

**controllers/emails_controller** (*talks to*)-><br> **services/emails_service.rb** (*talks to*) -><br> either **providers/send_grid.rb** or **providers/mailgun.rb**

```
providers
  send_grid.rb       # Massage user input to match sendgrid format; send email through sendgrid API.
  mailgun.rb        # Massage user input to match mailgun format; send email through mailgun API.
services
  emails_service.rb   # Use sendgrid provider to send email. In case of failure, fallback to mailgun provider.
controllers
  emails_controller.rb         # Post /emails to send email using email service

spec                # Unit tests
  providers
    send_grid_spec.rb   
    mailgun_spec.rb
  services
    emails_service_spec.rb
  controllers
    emails_controller_spec.rb

## TODO
* check what's missing in README

## Nice to have
Validation on user inputs before sending them to providers. Because the provider validations are not reliable in the sense that they are not consistent. eg. subject is a required field in SendGrid but is not required in Mailgun.

Feedback is always welcome 🤗

