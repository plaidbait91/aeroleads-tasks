module Tools
  class CallNumbersListInput < Anthropic::BaseModel
    required :numbers, Anthropic::ArrayOf[String], doc: "List of phone numbers in E.164 format to call"
  end

  class CallNumbersList < Anthropic::BaseTool
    doc "Make calls to a list of phone numbers"

    input_schema CallNumbersListInput

    def call(input)
      from = ENV["TWILIO_FROM_NUMBER"]
      twiml_url = ENV["TWILIO_TWIML_URL"]
      callback_host = ENV["NGROK_URL"]
      callback_url = "#{callback_host}/status"

      numbers = input.numbers

      service = CallService.new(
        from_number: from,
        twiml_url: twiml_url,
        status_callback_url: callback_url
      )

      results = service.call_all(numbers: numbers)
      success = results.count { |key, value| value == 'success' }

      { status: "completed", message: "Successfully initiated calls to #{success}/#{numbers.size} numbers", results: results}
    end
  end
end