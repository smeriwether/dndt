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
   restaurants = all_restaurants

   if !params['quiet'].nil?
     quiet_restaurants = restaurants.select do |restaurant|
       restaurant['quiet']
     end

     if quiet_restaurants.count > 0
       restaurants = quiet_restaurants
     end
   end

   if !params['cheap'].nil?
     cheap_restaurants = restaurants.select do |restaurant|
       restaurant['cheap']
     end

     if cheap_restaurants.count > 0
       restaurants = cheap_restaurants
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
   @restaurants = (all_restaurants || []).sort_by { |r| r['name'] }
   erb :all
 end

 get '/edit' do
   @restaurant = find_restaurant(params['name'])
   erb :edit
 end

 post '/create' do
  begin
    add_restaurant(params['name'], !params['quiet'].nil?, !params['cheap'].nil?)
    redirect '/'
  rescue => e
    puts "Error creating restaurant #{e}"
    redirect '/add'
  end
 end

 post '/update' do
  begin
    update_restaurant(params['name'], !params['quiet'].nil?, !params['cheap'].nil?)
    redirect '/'
  rescue => e
    puts "Error updating restaurant #{e}"
    redirect '/edit'
  end
 end

 def add_restaurant(name, quiet, cheap)
   restaurants = all_restaurants
   File.write(FILE_PATH, {
    JSON_KEY => [
      restaurants || [],
      { 'name' => name, 'quiet': quiet, 'cheap': cheap },
    ].flatten
   }.to_json)
 end

 def update_restaurant(name, quiet, cheap)
   restaurant = find_restaurant(name)
   other_restaurants = all_restaurants - [restaurant]
   File.write(FILE_PATH, {
    JSON_KEY => [
      other_restaurants || [],
      { 'name' => name, 'quiet': quiet, 'cheap': cheap },
    ].flatten
   }.to_json)
 end

 def find_restaurant(name)
   all_restaurants.find { |r| r['name'] == name }
 end

 def all_restaurants
   begin
     file = File.open(FILE_PATH, 'a+')
     contents = file.read
     if contents.empty?
       contents = "{}"
     end

     JSON.parse(contents)[JSON_KEY]
   ensure
     file.close
   end
 end
