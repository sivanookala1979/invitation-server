class User < ActiveRecord::Base
  def as_json(options = {})
    options = super(options)
    options[:image_url] = (image = Images.find_by_id(image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
    options
  end
end
