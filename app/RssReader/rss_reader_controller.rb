require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'rexml/document'

class RssReaderController < Rho::RhoController
  include BrowserHelper
  SERVER_ADDRESS = "http://www.ruby-lang.org/ja/feeds/news.rss"
  
  def index
    @rssreaders = RssReader.find(:all)
    render :back => '/app'
  end
  
  def show
    @rssreader = RssReader.find(@params["id"])
    if @rssreader
      render :back => url_for(:action => :index)
    else
      redirect_to :action => :index
    end
  end
  
  def refresh
    http = Rho::AsyncHttp.get(:url => SERVER_ADDRESS)
    if http && http["status"] == "ok"
      RssReader.delete_all
      rexml = REXML::Document.new(http["body"])
      rexml.root.elements["channel"].each_element("item") do |xml|
        title = xml.elements["title"].get_text
        description = xml.elements["description"].get_text
        RssReader.create(:title => title, :description => description)
      end
    else
      Alert.show_popup("データの取得に失敗しました。")
    end
    
    @rssreaders = RssReader.find(:all)
    render :action => :index, :back => '/app'
  end
end