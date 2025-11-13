class CallService
  def initialize(from_number:, twiml_url:, status_callback_url:)
    @from_number        = from_number
    @twiml_url          = twiml_url
    @status_callback_url= status_callback_url
    @twilio_client      = TwilioService.new
  end

  def call_all(numbers:)
    results = Hash.new
    numbers.each do |to_number|
      # create a DB record first
      record = CallLog.create!(to: to_number, from: @from_number, status: 'queued')
      begin
        call = @twilio_client.make_call(
          to:                    to_number,
          from:                  @from_number,
          url:                   @twiml_url,
          status_callback_url:   @status_callback_url,
          status_callback_events: %w[initiated ringing answered completed]
        )
        record.update!(twilio_sid: call.sid, status: call.status)
      rescue Twilio::REST::RestError => e
        results[to_number] = 'failed'
        record.update!(status: 'failed', error_message: e.message)
      end

      results[to_number] = 'success'
    end

    results
  end
end
