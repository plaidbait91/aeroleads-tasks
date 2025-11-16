require_relative '../../lib/tools/call_numbers_list'
require_relative '../../lib/tools/get_filtered_numbers'

class AgentService
  def initialize
    @client = Anthropic::Client.new
    @model = "claude-haiku-4-5-20251001"
    @tools = {"filter" => Tools::GetFilteredNumbers.new, "call" => Tools::CallNumbersList.new}
  end

  def call(input:, tool_strings:)
    @client.beta.messages.tool_runner(
      model: @model,
      max_tokens: 1024,
      system_: "Current system time is #{Time.now.localtime}",
      messages: [
        {role: "user", content: input}
      ],
      tools: tool_strings.map { |tool| @tools[tool] }
    ).each_message do |message|
      text_blocks = message.content.grep_v(Anthropic::Models::Beta::BetaToolUseBlock)
      message = text_blocks.first&.text || ''
      Turbo::StreamsChannel.broadcast_append_to(
        "messages",
        target: "messages",
        partial: "calls/agent_message",
        locals: { message: message }
      )
    end
    
  end
end
