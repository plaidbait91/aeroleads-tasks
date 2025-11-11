class CallsController < ApplicationController
  def new
    @call_logs = CallLog.all
  end

  def call
    input = params[:numbers]
    list_input = input.to_s.split("\n")
    numbers = list_input.map(&:strip).reject(&:blank?)

    from = ENV["TWILIO_FROM_NUMBER"]
    twiml_url = ENV["TWILIO_TWIML_URL"]
    callback_host = ENV["NGROK_URL"]
    callback_url = "#{callback_host}/status"

    service = CallService.new(
      numbers: numbers,
      from_number: from,
      twiml_url: twiml_url,
      status_callback_url: callback_url
    )

    service.call_all
  end

  def call_with_agent
  end
end
