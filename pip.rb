# encoding: utf-8

require 'compass'
require 'sinatra'
require 'haml'
require 'koala'
require 'mongo'
require 'uri'

class Meetup 
  attr_reader :date, :fb_event_id, :attending, :talks
  def initialize(m)
    @talks = []
    if ENV['MONGOLAB_URI']
      uri = URI.parse(ENV['MONGOLAB_URI'])
      mongo = Mongo::Connection.from_uri(ENV['MONGOLAB_URI']).db(uri.path.gsub(/^\//, ''))   
    else
      mongo = Mongo::Connection.new().db('pip')   
    end
    mongo.collection('talks').find.sort(:_id,:desc).limit(3).each do |t|
      @talks << Talk.new(t)
    end 

    @date = m[:date]
    @fb_event_id = m[:fb_event_id]
    
    @attending = []
    if ENV['API_KEY'] and ENV['APP_SECRET'] 
      oauth = Koala::Facebook::OAuth.new(ENV['API_KEY'], ENV['APP_SECRET'])
      fb = Koala::Facebook::API.new(oauth.get_app_access_token) 
      @attending = fb.get_connections(@fb_event_id,'attending').map {|person| {:name => person["name"], :src => fb.get_picture(person["id"])}}
    end

  end 
end

class Talk
  attr_reader :title, :speaker, :description, :img  
  def initialize(t)
    @title = t['title']
    @speaker = t['speaker']
    @description = t['description']
    fb = Koala::Facebook::API.new
    @img = fb.get_picture(t['fb'])
  end
  
end

configure do
  set :haml, {:format => :html5, :escape_html => false, :encoding => "utf-8"}
  set :sass, {:style => :compact, :debug_info => false}
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass(:"stylesheets/#{params[:name]}.css", Compass.sass_engine_options )
end

get '/' do 
  
  meetup = Meetup.new({date: "Venerd&igrave; 29 Giugno, ore 19:00", fb_event_id: "386199931443394"})
  
  @date = meetup.date 
  @fb_event_id = meetup.fb_event_id
  @attending = meetup.attending   
  @talks = meetup.talks.reverse

  haml :"index.html"
end