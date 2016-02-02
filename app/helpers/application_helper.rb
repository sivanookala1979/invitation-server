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
end
