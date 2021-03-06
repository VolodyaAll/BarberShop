#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'pony'
require 'sqlite3'

configure do
  db = get_db

  db.execute 'CREATE TABLE IF NOT EXISTS
  "Users"
  (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "username" TEXT,
    "phone" TEXT,
    "datestamp" TEXT,
    "barber" TEXT,
    "color" TEXT
  )'

  db.execute 'CREATE TABLE IF NOT EXISTS
  "Barbers"
  (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "barber" TEXT UNIQUE
  )'

  arr = ['Walter White', 'Jessie Pinkman', 'Gus Fring']

  arr.each do |name|
    db.execute 'INSERT OR IGNORE INTO Barbers(barber) VALUES(?)', name
  end

end

get '/' do
  erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/about' do
  @error = 'Something wrong'
  erb :about
end

get '/visit' do
  @db = get_db
  erb :visit
end

get '/contacts' do
  erb :contacts
end

get '/showusers' do
  @db = get_db
  erb :showusers
end

post '/visit' do
  @username = params[:username]
  @phone = params[:phone]
  @date_time = params[:date_time]
  @barber = params[:barber]
  @color = params[:color]
  @db = get_db

  hh = {username: 'Введите имя',
    phone: 'Введите телефон',
    date_time: 'Введите дату и время'}

  @error = hh.select{|key,_| params[key] == ""}.values.join(", ")

  if @error != ''
    return erb :visit
  end

  @db.execute 'INSERT INTO
    Users
    (
      username,
      phone,
      datestamp,
      barber,
      color
    )
    values ( ?, ?, ?, ?, ?)',
    [@username, @phone, @date_time, @barber, @color]

  erb "Dear #{@username}, we will be waiting for you at #{@date_time}. Your barber is #{@barber}, Color: #{@color}. See you! <a href=\"http://localhost:4567\">На главную</a>"

end

post '/contacts' do
  @email = params["email"]
  @message = params["message"]
  hh = {email: 'Введите Email',
    message: 'Введите сообщение'}

  @error = hh.select{|key,_| params[key] == ""}.values.join(", ")

  if @error == ''
    f = File.open("./public/contacts.txt", "a")
    f.write("Email: #{params[:email]}, Message: #{params[:message]}.\n")
    f.close

    Pony.mail(to: 'sharaivladimir2@gmail.com', from: @email, body: @message,
      via: :smtp,
      via_options: {
      address: 'smtp.gmail.com',
      port: '587',
      enable_starttls_auto: true,
      user_name: 'sharaivladimir2@gmail.com',
      password: 'Your_password',
      authentication: :plain, # :plain, :login, :cram_md5, no auth by default
      domain: "localhost.localdomain"})

    erb "We will send our answer to #{params[:email]}. See you! <a href=\"http://localhost:4567\">На главную</a>"
  else
    return erb :contacts
  end
end

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end