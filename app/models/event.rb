class Event < ActiveRecord::Base
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
