require 'compass'
require 'sinatra'
require 'haml'
require 'koala'

class Talk
  attr_accessor :title, :speaker, :description
  attr_reader :img  
  def initialize(t)
    @title = t[:title]
    @speaker = t[:speaker]
    @description = t[:description]
    fb = Koala::Facebook::API.new
    @img = fb.get_picture(t[:fb])
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
  
  @fb_event_id = "235571656541303"
  @attending = []
  
  if ENV['API_KEY'] and ENV['APP_SECRET'] 
    oauth = Koala::Facebook::OAuth.new(ENV['API_KEY'], ENV['APP_SECRET'])
    fb = Koala::Facebook::API.new(oauth.get_app_access_token) 
    @attending = fb.get_connections(@fb_event_id,'attending').map {|person| {:name => person["name"], :src => fb.get_picture(person["id"])}}
  end
    
  @talks = [
    Talk.new({:title => "Intro allo sviluppo iOS", :speaker => "Giacomo Saccardo", :description => "Una overview che cerca di toccare tutti i passaggi principali per sviluppare app: codice, ciclo di vita dell'app, rapporti apple-developers&hellip;", :fb => 'saccardogiacomo'}),
    
    Talk.new({title: 'Thinking Sphinx', speaker: 'Antonio Passamani', description: 'Si parler&agrave; di Sphinx e della ricerca (di testo e posizioni) in generale. Ci sono scaffolds per costruire il proprio sito in Ruby on Rails con funzione ricerca partendo da zero, con presentazione di un caso concreto di ricerca geo.', :fb => 'antonio.passamani'}),
    
    Talk.new({title: 'Regexp', speaker: 'Filippo De Pretto', description: 'Pulisci, filtra, carica, valida i dati e sostituisci le occorrenze necessarie. In una riga. Questo e molto altro, con le potentissime espressioni regolari. Inventate nel 1950, ora presenti e utilizzate ovunque.', :fb => 'filnik'})]

  haml :"index.html"
end