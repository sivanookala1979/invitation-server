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
end
