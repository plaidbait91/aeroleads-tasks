class AddTwilioSidToCallLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :call_logs, :twilio_sid, :string
  end
end
