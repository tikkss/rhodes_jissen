require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'rho/rhocontact'

class ContactController < Rho::RhoController
  include BrowserHelper
  PER_PAGE = 3
  
  def index
    @count = Rho::RhoContact.find(:count)
    render :back => '/app'
  end
  
  def list
    @contacts = Rho::RhoContact.find(:all)
    render :back => url_for(:action => :index)
  end
  
  def new
    @contact = {}
    render :back => url_for(:action => :index)
  end
  
  def create
    Rho::RhoContact.create!(@params["contact"])
    Alert.show_popup("作成しました。")
    redirect :action => :list
  end
  
  def show
    @contact = Rho::RhoContact.find(@params["id"])
    if @contact
      render :back => url_for(:action => :list)
    else
      redirect :action => :list
    end
  end
  
  def edit
    @contact = Rho::RhoContact.find(@params["id"])
    if @contact
      render :back => url_for(:action => :show, :id => @contact["id"])
    else
      redirect :action => :list
    end
  end
  
  def update
    Rho::RhoContact.update_attributes(@params["contact"])
    Alert.show_popup("更新しました。")
    redirect :action => :list
  end
  
  def delete
    Alert.show_popup(
      :title => "警告",
      :icon => :alert,
      :message => "本当に削除してよろしいですか？",
      :buttons => ["OK", {:id => "cancel", :title => "キャンセル"}],
      :callback => url_for(:action => :delete_callback, :id => @params["id"])
    )
    
    render :string => "wait..."
  end
  
  def delete_callback
    if @params["button_id"] == "OK"
      Rho::RhoContact.destroy(@params["id"])
      Alert.show_popup("削除しました")
    else
      Alert.show_popup("削除をキャンセルしました。")
    end
    
    WebView.navigate(url_for(:action => :list))
  end
  
  def init
    contacts = Rho::RhoContact.find(:all, :select => ["last_name"])
    contacts.each do |c|
      Rho::RhoContact.destroy(c[1]["id"]) if c[1]["last_name"] == "sample"
    end
    
    prefix = "A"
    15.times do |n|
      attr = {
        "first_name" => "#{prefix}-name",
        "last_name" => "sample",
        "mobile_number" => "+123456789012"
      }
      Rho::RhoContact.create!(attr)
      prefix.next!
    end
    
    Alert.show_popup("テストデータを投入しました。")
    redirect :action => :index
  end
  
  def paginate
    page = @params["page"] ? @params["page"].to_i : 0
    offset = PER_PAGE * page
    @count = Rho::RhoContact.find(:count)
    @contacts = Rho::RhoContact.find(
      :all,
      :per_page => PER_PAGE,
      :offset => offset
    )
    @next_page = page + 1 if @count > offset + 1
    @prev_page = page - 1 if page > 0
    
    render :back => url_for(:action => :index)
  end
end