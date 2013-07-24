require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'rho/rhoevent'
require 'time'

class EventController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  
  def index
    render
  end
  
  def choose_date
    DateTimePicker.choose(
      url_for(:action => :choose_date_callback),
      @params["title"],
      Time.new,
      0,
      Marshal.dump(@params["field_key"])
    )
  end
  
  def choose_date_callback
    if @params["status"] == "ok"
      key = Marshal.load(@params["opaque"])
      result = Time.at(@params["result"].to_i).strftime('%F %T')
      WebView.execute_js('setFieldValue("' + key + '","' + result + '");')
    end
  end
end