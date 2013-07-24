require 'rho/rhocontroller'
require 'helpers/browser_helper'

class SignatureController < Rho::RhoController
  include BrowserHelper
  
  def index
    @signatures = Signature.find(:all)
    render :back => '/app'
  end
  
  def take_signature
    Rho::SignatureCapture.take(
      url_for(:action => :signature_callback),
      {
        :imageFormat => "jpg",
        :penColor => 0xff0000,
        :penWidth => 5,
        :border => true,
        :bgColor => 0x00ff00
      }
    )
    
    redirect :action => :index
  end
  
  def signature_callback
    if @params["status"] == "ok"
      Signature.create({:signature_uri => @params["signature_uri"]})
    end
    
    WebView.navigate(url_for(:action => :index))
  end
end