class TwilioService
  def initialize
    @client = Twilio::REST::Client.new(
      ENV["TWILIO_ACCOUNT_SID"],
      ENV["TWILIO_AUTH_TOKEN"]
    )
  end

  # to: E.164 number
  # from: your Twilio number
  # status_callback_url: your webhook endpoint
  # status_callback_events: array of strings like ['initiated','ringing','answered','completed']
  def make_call(to:, from:, url:, status_callback_url:, status_callback_events: ['completed'])
    @client.calls.create(
      to:                     to,
      from:                   from,
      url:                    url,
      status_callback:        status_callback_url,
      status_callback_event:  status_callback_events,
      status_callback_method: "POST"
    )
  end
end
