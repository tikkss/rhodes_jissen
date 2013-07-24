require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'time'

class TimePickerController < Rho::RhoController
  include BrowserHelper
  
  def index
    render :back => :index
  end
  
  def choose
    DateTimePicker.choose(
      url_for(:action => :choose_callback),
      "選択してください",
      Time.new,
      @params["flg"].to_i,
      Marshal.dump(@params["flg"])
    )
    
    redirect :action => :index
  end
  
  def choose_callback
    if @params["status"] == "ok"
      time = Time.at(@params["result"].to_i)
      flg = Marshal.load(@params["opaque"])
      case flg
      when "0"
        format = '%F %T'
      when "1"
        format = '%F'
      when "2"
        format = '%T'
      else
        format = '%F %T'
      end
      Alert.show_popup(
        :message => "#{time.strftime(format)}",
        :title => "あなたが選択した時間",
        :buttons => ["了解"]
      )
      WebView.execute_js('Time_Picker_Set("' + time.strftime(format) + '");')
    else
      WebView.navigate(url_for(:action => :index))
    end
  end
  
  def choose_range
    DateTimePicker.choose_with_range(
      url_for(:action => :choose_callback),
      "選択してください",
      Time.new,
      @params["format"].to_i,
      Marshal.dump(@params["format"]),
      Time.now(),
      Time.now() + 604800
    )
    
    redirect :action => :index
  end
end