class CallAgentJob < ApplicationJob
  queue_as :default

  def perform(input:, tool_strings:)
    agent = AgentService.new
    agent.call(input: input, tool_strings: tool_strings)
  end
end
