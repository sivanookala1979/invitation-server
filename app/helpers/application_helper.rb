module ApplicationHelper


  def get_time_format(date)
    result=''
    if !date.blank?
      result = date.strftime("%d %b %Y")
    end
    result
  end
  def get_index_text(value)
    "<div class=\"row\">
  <div class=\"col-sm-12\" style=\"padding-left: 10px;\">
<div class=\"head_style\">" "#{value}</div></div></div>".html_safe
  end

  def getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2)
    radius = 6371 ## Radius of the earth in km
    dLat = deg2rad(lat2-lat1)  ## deg2rad below
    dLon = deg2rad(lon2-lon1)
    a = Math::sin(dLat/2) * Math::sin(dLat/2)+Math::cos(deg2rad(lat1)) * Math::cos(deg2rad(lat2)) * Math::sin(dLon/2) * Math::sin(dLon/2)
    c = 2 * Math::atan2(Math.sqrt(a), Math::sqrt(1-a))
    d = radius * c; ## Distance in km
    return d
  end


  def deg2rad(deg)
    return deg * (Math::PI/180)
  end

  def self.get_otp
    word = [('1'..'9')].map { |i| i.to_a }.flatten
    (0...6).map { word[rand(word.length)] }.join
  end

  def distance_of_time_in_words(from_time, to_time = 0, options = {})
    options = {
        scope: :'datetime.distance_in_words'
    }.merge!(options)

    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    from_time, to_time = to_time, from_time if from_time > to_time
    distance_in_minutes = ((to_time - from_time)/60.0).round
    distance_in_seconds = (to_time - from_time).round

    I18n.with_options :locale => options[:locale], :scope => options[:scope] do |locale|
      case distance_in_minutes
        when 0..1
          return distance_in_minutes == 0 ?
              locale.t(:less_than_x_minutes, :count => 1) :
              locale.t(:x_minutes, :count => distance_in_minutes) unless options[:include_seconds]

          case distance_in_seconds
            when 0..4   then locale.t :less_than_x_seconds, :count => 5
            when 5..9   then locale.t :less_than_x_seconds, :count => 10
            when 10..19 then locale.t :less_than_x_seconds, :count => 20
            when 20..39 then locale.t :half_a_minute
            when 40..59 then locale.t :less_than_x_minutes, :count => 1
            else             locale.t :x_minutes,           :count => 1
          end

        when 2...45           then locale.t :x_minutes,      :count => distance_in_minutes
        when 45...90          then locale.t :about_x_hours,  :count => 1
        # 90 mins up to 24 hours
        when 90...1440        then locale.t :about_x_hours,  :count => (distance_in_minutes.to_f / 60.0).round
        # 24 hours up to 42 hours
        when 1440...2520      then locale.t :x_days,         :count => 1
        # 42 hours up to 30 days
        when 2520...43200     then locale.t :x_days,         :count => (distance_in_minutes.to_f / 1440.0).round
        # 30 days up to 60 days
        when 43200...86400    then locale.t :about_x_months, :count => (distance_in_minutes.to_f / 43200.0).round
        # 60 days up to 365 days
        when 86400...525600   then locale.t :x_months,       :count => (distance_in_minutes.to_f / 43200.0).round
        else
          if from_time.acts_like?(:time) && to_time.acts_like?(:time)
            fyear = from_time.year
            fyear += 1 if from_time.month >= 3
            tyear = to_time.year
            tyear -= 1 if to_time.month < 3
            leap_years = (fyear > tyear) ? 0 : (fyear..tyear).count{|x| Date.leap?(x)}
            minute_offset_for_leap_year = leap_years * 1440
            # Discount the leap year days when calculating year distance.
            # e.g. if there are 20 leap year days between 2 dates having the same day
            # and month then the based on 365 days calculation
            # the distance in years will come out to over 80 years when in written
            # English it would read better as about 80 years.
            minutes_with_offset = distance_in_minutes - minute_offset_for_leap_year
          else
            minutes_with_offset = distance_in_minutes
          end
          remainder                   = (minutes_with_offset % MINUTES_IN_YEAR)
          distance_in_years           = (minutes_with_offset.div MINUTES_IN_YEAR)
          if remainder < MINUTES_IN_QUARTER_YEAR
            locale.t(:about_x_years,  :count => distance_in_years)
          elsif remainder < MINUTES_IN_THREE_QUARTERS_YEAR
            locale.t(:over_x_years,   :count => distance_in_years)
          else
            locale.t(:almost_x_years, :count => distance_in_years + 1)
          end
      end
    end
  end



  def self.upload_image(params_image)
    image = Images.new
    image.image_path = params_image
    image.save
    path = Rails.root.to_s+"/public"+image.image_path.url(:original).split('?')[0]
    url = "cwebp -q 80 #{path} -o #{path.gsub('.jpg', '.webp').gsub('.png', '.webp')}"
    puts url
    system(url)
    image
  end

  def save_image(decode_image)
    image = Images.new
    image.image_path =process_photo(decode_image)
    image.save
    url = "cwebp -q 80 #{Rails.root.to_s+"/public/assets/image/#{image.id}/original/picture.png"} -o #{Rails.root.to_s+"/public/assets/image/#{image.id}/original/picture.webp"}"
    system(url)
    image
  end

  def process_photo(photo)
    data = nil
    if !photo.blank?
      data = StringIO.new(Base64.decode64(photo))
      data.class.class_eval { attr_accessor :original_filename, :content_type }
      data.original_filename = 'picture.png'
      data.content_type = 'image/png'
    end
    data
  end


  def self.get_root_url
    "http://invtapp.cerone-software.com/"
  end

end
