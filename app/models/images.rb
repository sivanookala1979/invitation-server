class Images < ActiveRecord::Base
  has_attached_file :image_path, :styles => {:small => "350x350>", :large=>"650x650>"},
                    :url  => "/assets/image/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/image/:id/:style/:basename.:extension"

  validates_attachment_presence :image_path
  validates_attachment_size :image_path, :less_than => 5.megabytes
  validates_attachment_content_type :image_path, :content_type => ['image/jpeg', 'image/png']
end
