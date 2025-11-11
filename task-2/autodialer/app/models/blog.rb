class Blog < ApplicationRecord
    after_create_commit :broadcast_append
    after_update_commit :broadcast_replace

    private

    def broadcast_append
      # If this is the first blog, remove the "No blogs yet..." message
      if Blog.count == 1
        broadcast_remove_to "blogs", target: "no_blogs_message"
      end
      
      broadcast_append_to "blogs", target: "blogs_list", partial: "blogs/blog", locals: { blog: self }
    end

    def broadcast_replace      
      broadcast_replace_to "blogs", target: "blog_#{id}", partial: "blogs/blog", locals: { blog: self }
    end
end
