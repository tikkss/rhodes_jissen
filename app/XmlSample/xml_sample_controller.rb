require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'rexml/document'

class XmlSampleController < Rho::RhoController
  include BrowserHelper
  
  SERVER_ADDRESS = "http://192.168.0.13:3000"
  
  def index
    http = Rho::AsyncHttp.get(:url => "#{SERVER_ADDRESS}/xml_samples.xml")
    puts http
    if http && http["status"] == "ok"
      XmlSample.delete_all
      rexml = REXML::Document.new(http["body"])
      rexml.elements["xml-samples"].each_element("xml-sample") do |xml|
        title = xml.elements["title"].get_text
        content = xml.elements["content"].get_text
        id = xml.elements["id"].get_text
        XmlSample.create(:content => content, :title => title, :id => id)
      end
    else
      Alert.show_popup("データの取得に失敗しました。")
    end
    
    @xmlsamples = XmlSample.find(:all)
    puts "=========",@xmlsamples
    render :back => '/app'
  end
  
  def show
    @xmlsample = XmlSample.find(@params["id"])
    if @xmlsample
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end
  
  def new
    @xmlsample = XmlSample.new
    render :action => :new, :back => url_for(:action => :index)
  end
  
  def edit
    @xmlsample = XmlSample.find(@params["id"])
    if @xmlsample
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end
  
  def create
    attr = ""
    @params["xmlsample"].each do |k, v|
      attr += "<#{k}>#{v}</#{k}>"
    end
    rexml = "<xmlsample>#{attr}</xmlsample>"
    Rho::AsyncHttp.post(
      :url => "#{SERVER_ADDRESS}/xml_samples.xml",
      :body => "xml=#{rexml}",
      :callback => url_for(:action => :create_callback)
    )
    render :string => "wait..."
  end
  
  def create_callback
    msg = "作成に失敗しました。"
    if @params["status"] == "ok"
      rexml = REXML::Document.new(@params["body"])
      if rexml.elements["hash/status"].get_text == "OK"
        msg = rexml.elements["hash/msg"].get_text
      end
    end
    
    Alert.show_popup(msg)
    WebView.navigate(url_for(:action => :index))
  end
  
  def update
    id = @params["id"]
    attr = ""
    @params["xmlsample"].each do |k, v|
      attr += "<#{k}>#{v}</#{k}>"
    end
    rexml = "<xmlsample>#{attr}</xmlsample>"
    Rho::AsyncHttp.post(
      :url => "#{SERVER_ADDRESS}/xml_samples/#{id}.xml",
      :body => "xml=#{rexml}",
      :http_command => "PUT",
      :callback => url_for(:action => :update_callback)
    )
    render :string => "wait..."
  end
  
  def update_callback
    msg = "更新に失敗しました。"
    if @params["status"] == "ok"
      rexml = REXML::Document.new(@params["body"])
      if rexml.elements["hash/status"].get_text == "OK"
        msg = rexml.elements["hash/msg"].get_text
      end
    end
    
    Alert.show_popup(msg)
    WebView.navigate(url_for(:action => :index))
  end
  
  def delete
    xmlsample = XmlSample.find(@params["id"])
    id = xmlsample.id
    Rho::AsyncHttp.post(
      :url => "#{SERVER_ADDRESS}/xml_samples/#{id}.xml",
      :http_command => "DELETE",
      :callback => url_for(:action => :delete_callback)
    )
    render :string => "wait..."
  end
  
  def delete_callback
    msg = "削除に失敗しました。"
    if @params["status"] == "ok"
      rexml = REXML::Document.new(@params["body"])
      if rexml.elements["hash/status"].get_text == "OK"
        msg = rexml.elements["hash/msg"].get_text
      end
    end
    
    Alert.show_popup(msg)
    WebView.navigate(url_for(:action => :index))
  end
end