class Blog < ApplicationRecord
    after_create_commit :broadcast_append
    private

    def broadcast_append
      # If this is the first call log, remove the "No logs yet..." message
      if CallLog.count == 1
        broadcast_remove_to "call_logs", target: "no_logs_message"
      end
      
      broadcast_append_to "call_logs", partial: "calls/call_log", locals: { call_log: self }
    end

    def broadcast_replace      
      broadcast_replace_to "call_logs", partial: "calls/call_log", locals: { call_log: self }
    end
end
