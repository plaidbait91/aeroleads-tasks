require 'time'

class GetFilteredNumbersInput < Anthropic::BaseModel
  optional :last_n, Integer, doc: "The last n calls to retrieve"
  optional :after_time, String, doc: "Calls dialed after timestamp in ISO8601 format (e.g., “2025-11-13T07:00:00Z”)"
  optional :before_time, String, doc: "Calls dialed before timestamp in ISO8601 format (e.g., “2025-11-13T09:00:00Z”)"
  optional :min_duration, Integer, doc: "Calls with duration (in seconds) ≥ this value"
  optional :numbers, Anthropic::ArrayOf[String], doc: "List of phone numbers in E.164 format, if specified in message"
  required :filters_present, Anthropic::Boolean, doc: "True if user has specified any filters (last n, before after times, duration etc.), False if they have just sent a list of numbers."
end

class GetFilteredNumbers < Anthropic::BaseTool
  doc "Retrieve numbers from filtered call logs, or list of numbers passed in message."

  input_schema GetFilteredNumbersInput

  def call(input)

    if !input.filters_present
      return { numbers: input.numbers.uniq }
    end

    logs = CallLog.all

    if input.after_time
      after_time = Time.iso8601(input.after_time)
      logs = logs.where("created_at >= ?", after_time)
    end

    if input.before_time
      before_time = Time.iso8601(input.before_time)
      logs = logs.where("created_at <= ?", before_time)
    end

    if input.min_duration
      logs = logs.where("duration >= ?", input.min_duration)
    end

    if input.last_n
      logs = logs.order(created_at: :desc).limit(input.last_n)
      numbers = logs.pluck(:to).uniq
    else
      numbers = logs.distinct.pluck(:to)
    end

    { numbers: numbers }
  end
end
