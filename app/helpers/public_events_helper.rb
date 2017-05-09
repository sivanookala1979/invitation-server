module PublicEventsHelper

  class PublicEventsList
    attr_accessor :id, :event_name, :event_theme, :start_time, :end_time, :entry_fee,:offer_amount, :description, :address, :is_weekend, :city, :service, :img_url,:is_favourite,:views

    def initialize(id, event_name, event_theme, start_time, end_time, entry_fee,offer_amount, description, address, is_weekend, city, service, img_url,is_favourite,views)
      @id = id
      @event_name = event_name
      @event_theme = event_theme
      @start_time = start_time
      @end_time = end_time
      @entry_fee = entry_fee
      @offer_amount = offer_amount
      @description =description
      @address =address
      @is_weekend =is_weekend
      @city =city
      @service =service
      @img_url = img_url
      @is_favourite = is_favourite
      @views = views
    end
  end
end
