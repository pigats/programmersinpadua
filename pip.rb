# encoding: utf-8

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
  
  @date = "Venerd&igrave; 29 Giugno, ore 19:00"
  @fb_event_id = "386199931443394"
  @attending = []
  
  if ENV['API_KEY'] and ENV['APP_SECRET'] 
    oauth = Koala::Facebook::OAuth.new(ENV['API_KEY'], ENV['APP_SECRET'])
    fb = Koala::Facebook::API.new(oauth.get_app_access_token) 
    @attending = fb.get_connections(@fb_event_id,'attending').map {|person| {:name => person["name"], :src => fb.get_picture(person["id"])}}
  end
    
  @talks = [
    Talk.new({:title => "Intro allo sviluppo iOS", :speaker => "Giacomo Saccardo", :description => "Una overview che cerca di toccare tutti i passaggi principali per sviluppare app: codice, ciclo di vita dell'app, rapporti apple-developers&hellip;", :fb => 'saccardogiacomo'}),
    
    Talk.new({:title => 'Thinking Sphinx', :speaker => 'Antonio Passamani', :description => 'Si parler&agrave; di Sphinx e della ricerca (di testo e posizioni) in generale. Ci sono scaffolds per costruire il proprio sito in Ruby on Rails con funzione ricerca partendo da zero, con presentazione di un caso concreto di ricerca geo.', :fb => 'antonio.passamani'}),
    
    Talk.new({:title => 'Regexp', :speaker => 'Filippo De Pretto', :description => 'Pulisci, filtra, carica, valida i dati e sostituisci le occorrenze necessarie. In una riga. Questo e molto altro, con le potentissime espressioni regolari. Inventate nel 1950, ora presenti e utilizzate ovunque.', :fb => 'filnik'}),
    
    Talk.new({:title => 'Cyberpediatria', :speaker => 'Roberto Mancin', :description => "Pediatric neuroinformatics & Child's Brain Computer Interface, Mind Reader for Robotherapy & Augmentative Telecommunication in Padua's Pediatric Intensive Care Unit (PICU): idee per stage di cyberpediatria innovativi.", :fb => 'roberto.mancin' }),
    
    Talk.new({:title => 'Introduzione alla UX', :speaker => 'Andrea Collet', :description => "User Experience - Facciamo un po' di luce su esperienza e interazione con il prodotto digitale e di ciò che è essenziale conoscere per semplificare la vita all'utente.", :fb => '100003786820159' }),
    
    Talk.new({:title => "Lean Startup all'Italiana", :speaker => 'Nicola Junior Vitto', :description => "La Lean Startup e il Customer Development hanno cambiato il modo in cui realizzare nuove aziende in USA e stiamo iniziando ad apprezzarne i vantaggi anche in Europa e in Italia. Ma il nostro ecosistema di startup e venture capital è molto diverso rispetto a quello oltreoceano...come applicare quindi le metodologie lean nel nostro Paese?", :fb => 'njvitto' }),   
    
    Talk.new({:title => "ISF e OpenHospital", :speaker => 'Alessandro Domanico', :description => "OpenHospital è un software free e opensource per la gestione e raccolta dati di piccoli ospedali rurali nei Paesi in Via di Sviluppo (PVS). Nato nel 2006 dalla collaborazione tra Informatici Senza Frontiere (ISF) e Amici di Angal (Uganda) è ora utilizzato in diversi paesi in Africa. Frameworks: Java Swing/AWT, MySQL, JasperReports.", :fb => 'alessandro.domanico1' }),
    
    Talk.new({:title => "Introduzione a Python", :speaker => 'Filippo De Pretto', :description => "Una cosa accomuna Star Wars, Google e la NASA: Python! Un linguaggio semplice, flessibile, estendibile e potente. Vedremo perché, quando usarlo e perché per molti è diventato il linguaggio definitivo.", :fb => 'filnik' }),
    
    Talk.new({:title => "Web dev con Django", :speaker => 'Flavio Marcato', :description => "Django è un framework pensato per il web. Come strumento è progettato per l'essere intuitivo, pulito e potente; il tutto grazie al supporto di Python. Tali obiettivi sono perseguiti da una filofia orientata alla massima automazione e al DRY principle, implementati entrambi da uno stile di progettazione a tre livelli: Modelli, Viste e Template. Infine, applicazioni web scritte in Django garantiscono al cliente un prodotto elegante e in tempi brevi. ", :fb => 'WingRunner' }),
    
    Talk.new({:title => "It Shoudn't work that way", :speaker => 'Hoang Chau Huynh', :description => "Il concetto di \"affordance\" è sicuramente uno dei cardini dell'user experience e dell'usabilità. Nonostante sia un argomento ipertrattato e spesso anche abusato dagli addetti al settore, è sicuramente un piccolo tassello di conoscenza utile e versatile per ogni professionista che si occupi di interfacce e utenti. E' un argomento di cui vale la pena di trattare e di cui voglio fornire la mia particolare chiave di lettura perchè capace di innescare comprensione e immaginazione ad ogni livello di progettazione. ", :fb => 'hoangchau.huynh' }),        
    
    Talk.new({:title => "Programmers in Amsterdam", :speaker => 'Francesco Mattia', :description => "Dopo un anno passato ad Amsterdam come sviluppatore mobile, Francesco Mattia condivide con il PIP la sua esperienza. Tutto quello che vorreste sapere sulle community e sul mondo delle startup ad Amsterdam. ", :fb => 'fr4ncis' }),
    
    Talk.new({:title => "from JavaScript to CoffeeScript", :speaker => 'Stefano Ceschi Berrini', :description => "In questo talk verr&agrave; fatta, dopo aver introdotto CoffeeScript, una coding session 'live' nella quale si trasformer&agrave; del codice JavaScript in CoffeeScript e di quest'ultimo se ne illustreranno i vantaggi.", :fb => 'stefanoceschiberrini' }),
    
    ].last(3)

  haml :"index.html"
end