class CreateCallLogs < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    create_table :call_logs, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :from
      t.string :to
      t.string :status
      t.integer :duration

      t.timestamps
    end
  end
end
