class Event < ActiveRecord::Base
  def as_json(options = {})
    options = super(options)
    options[:image_path] = (image = Images.find_by_id(image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
    options
  end
  def self.date_scope(start_date, end_date)
    if start_date.blank? && end_date.blank?
      scoped
    elsif !start_date.blank? && end_date.blank?
      self.where('created_at >= ?', Date.parse(start_date).midnight)
    elsif start_date.blank? && !end_date.blank?
      self.where('created_at <= ?', Date.parse(end_date).midnight+1.day)
    else
      self.where('created_at >= ? and created_at <= ?', Date.parse(start_date).midnight, Date.parse(end_date).midnight+1.day)
    end
  end
end
