class AddPublishedToBlogs < ActiveRecord::Migration[8.1]
  def change
    add_column :blogs, :published, :boolean, default: false, null: false
  end
end
