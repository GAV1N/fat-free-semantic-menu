require 'rubygems'
require 'action_view'
require 'active_support'

class MenuItem
  include ActionView::Helpers::TagHelper,
          ActionView::Helpers::UrlHelper,
          ActionController::UrlWriter
  
  attr_accessor :children, :link
  
  def initialize(title, link, level, link_opts={})
    @title, @link, @level, @link_opts = title, link, level, link_opts
    @children = []
  end
  
  def add(title, link, link_opts={}, &block)
    returning(MenuItem.new(title, link, @level +1, link_opts)) do |adding|
      @children << adding
      yield adding if block_given?
    end
  end
  
  def to_s
    content_tag :li, link_to(@title, @link, @link_opts) + child_output, ({:class => 'active'} if active?)
  end
  
  def level_class
    "menu_level_#{@level}"
  end
  
  def child_output
    children.empty? ? '' : content_tag(:ul, @children.collect(&:to_s).join, :class => level_class)
  end
  
  def active?
    children.any?(&:active?) || on_current_page?
  end
  
  def on_current_page?
    if current_tab = controller.instance_variable_get("@current_tab")
      resp = @title.to_sym == current_tab
    else
      link = "" + @link != "/" ? @link.split('/').second : ""
      resp = link == controller.controller_name
    end
    resp
  end
  
  cattr_accessor :controller
  def controller # make it available to current_page? in UrlHelper
    @@controller
  end
  
  def add_semantic_menu_levels(menu,menu_items)
    menu_items.each do |menu_item|
      m = add_semantic_menu_item(menu,menu_item)
      add_semantic_menu_levels(m,menu_item[:children]) if menu_item[:children]
    end
  end

  def add_semantic_menu_item(menu,menu_item)
    @controller = controller # ActionView::Helpers::UrlHelper resets @controller to nil, breaking url_for
    menu.add menu_item[:text], url_for(menu_item[:url].merge(:only_path => true))
  end
end

class FatFreeSemanticMenu < MenuItem
  
  def initialize(controller, opts={},&block)
   @@controller = controller
    @opts       = {:class => 'tabs'}.merge opts
    @level      = 0
    @children   = []
    
    yield self if block_given?
  end

  def to_s
    content_tag(:ul, @children.collect(&:to_s).join, @opts)
  end
end

# Yep, monkey patch ActionView's UrlHelper
# All that changes here is s/@controller/controller
module ActionView
  module Helpers #:nodoc:
    module UrlHelper
      def current_page?(options)
        url_string = CGI.unescapeHTML(url_for(options))
        request = controller.request
        # We ignore any extra parameters in the request_uri if the 
        # submitted url doesn't have any either.  This lets the function
        # work with things like ?order=asc 
        if url_string.index("?")
          request_uri = request.request_uri
        else
          request_uri = request.request_uri.split('?').first
        end
        if url_string =~ /^\w+:\/\//
          url_string == "#{request.protocol}#{request.host_with_port}#{request_uri}"
        else
          url_string == request_uri
        end
      end
    end
  end
end
