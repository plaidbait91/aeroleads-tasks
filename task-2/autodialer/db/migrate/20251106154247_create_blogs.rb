class CreateBlogs < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    create_table :blogs, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :title
      t.string :author
      t.string :description

      t.timestamps
    end
  end
end
