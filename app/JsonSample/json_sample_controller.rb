require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'json'

class JsonSampleController < Rho::RhoController
  include BrowserHelper
  SERVER_ADDRESS = "http://192.168.0.13:3000"
  
  def index
    http = Rho::AsyncHttp.get(:url => "#{SERVER_ADDRESS}/json_samples.json")
    if http && http["status"] == "ok"
      JsonSample.delete_all
      http["body"].each{|j| JsonSample.create(j)}
    else
      Alert.show_popup("データの取得に失敗しました。")
    end
    
    @jsonsamples = JsonSample.find(:all)
    render :back => '/app'
  end
  
  def show
    @jsonsample = JsonSample.find(@params["id"])
    render :back => url_for(:action => :index)
  end
  
  def new
    @jsonsample = JsonSample.new
    render :back => url_for(:action => :index)
  end
  
  def edit
    @jsonsample = JsonSample.find(@params["id"])
    render :back => url_for(:action => :index)
  end
  
  def create
    json = ::JSON.generate(@params["jsonsample"])
    Rho::AsyncHttp.post(
      :url => "#{SERVER_ADDRESS}/json_samples.json",
      :body => "json=#{json}",
      :callback => url_for(:action => :create_callback)
    )
    
    render :string => "wait..."
  end
  
  def create_callback
    if @params["status"] == "ok"
      msg = @params["body"]["msg"]
    else
      msg = "データの作成に失敗しました。"
    end
    
    Alert.show_popup(msg)
    WebView.navigate(url_for(:action => :index))
  end
  
  def update
    id = @params["id"]
    json = JSON.generate(@params["jsonsample"])
    Rho::AsyncHttp.post(
      :url => "#{SERVER_ADDRESS}/json_samples/#{id}.json",
      :body => "json=#{json}",
      :http_command => "PUT",
      :callback => url_for(:action => "update_callback")
    )
    
    render :string => "wait..."
  end
  
  def update_callback
    if @params["status"] == "ok"
      msg = @params["body"]["msg"]
    else
      msg = "データの更新に失敗しました。"
    end
    
    Alert.show_popup(msg)
    WebView.navigate(url_for(:action => :index))
  end
  
  def delete
    jsonsample = JsonSample.find(@params["id"])
    id = jsonsample.id
    Rho::AsyncHttp.post(
      :url => "#{SERVER_ADDRESS}/json_samples/#{id}.json",
      :http_command => "DELETE",
      :callback => url_for(:action => :delete_callback)
    )
    
    render :string => "wait..."
  end
  
  def delete_callback
    if @params["status"] == "ok"
      msg = @params["body"]["msg"]
    else
      msg = "データの削除に失敗しました。"
    end
    
    Alert.show_popup(msg)
    WebView.navigate(url_for(:action => :index))
  end
end