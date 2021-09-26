 require 'sinatra'
 require 'pry'

 DISK_PATH = ENV.fetch('DISK_PATH', '.')
 FILE_PATH = "#{DISK_PATH}/restaurants.json"
 JSON_KEY = 'list'

 get '/' do
   @all_restaurants = all_restaurants
   erb :index
 end

 get '/find' do
   restaurants = all_restaurants[JSON_KEY]
   if !params['quiet'].nil?
     quiet_restaurants = restaurants.select do |restaurant|
       restaurant['quiet']
     end

     if quiet_restaurants.count > 0
       restaurants = quiet_restaurants
     end
   end

   rand = Random.rand(restaurants.count)
   @restaurant = restaurants[rand]
   erb :find
 end

 get '/add' do
   erb :add
 end

 get '/all' do
   @restaurants = all_restaurants[JSON_KEY] || []
   erb :all
 end

 post '/create' do
  begin
    add_restaurant(params['name'], !params['quiet'].nil?)
    redirect '/'
  rescue => e
    puts "Error creating restaurant #{e}"
    redirect '/add'
  end
 end

 def add_restaurant(name, quiet)
   restaurants = all_restaurants
   File.write(FILE_PATH, {
    JSON_KEY => [
      restaurants[JSON_KEY] || [],
      { 'name' => name, 'quiet': quiet },
    ].flatten
   }.to_json)
 end

 def all_restaurants
   begin
     file = File.open(FILE_PATH, 'a+')
     contents = file.read
     if contents.empty?
       contents = "{}"
     end

     JSON.parse(contents)
   ensure
     file.close
   end
 end
