class AddErrorMessageToCallLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :call_logs, :error_message, :string
  end
end
