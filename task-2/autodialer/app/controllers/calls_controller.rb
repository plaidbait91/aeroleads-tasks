class CallsController < ApplicationController
  def new
    @agent_mode = session[:agent_mode] || false
    @call_logs = CallLog.order(:created_at)
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
      from_number: from,
      twiml_url: twiml_url,
      status_callback_url: callback_url
    )

    service.call_all(numbers: numbers)
  end

  def call_with_agent
    input = params[:llm_input]
    tools = ["filter", "call"]
    Turbo::StreamsChannel.broadcast_append_to(
      "messages",
      target: "messages",
      partial: "calls/user_message",
      locals: { message: input }
    )

    agent = AgentService.new
    agent.call(input: input, tool_strings: tools)
    
  end

  def toggle_agent_mode
    session[:agent_mode] = params[:agent_mode] == "1"
    redirect_to call_path
  end
end
