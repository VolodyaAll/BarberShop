#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'pony'
require 'sqlite3'

configure do
	@db = SQLite3::Database.new 'barbershop.db'
	@db.execute 'CREATE TABLE IF NOT EXISTS 
	"Users"
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"username" TEXT,
		"phone" TEXT,
		"datestamp" TEXT,
		"barber" TEXT,
		"color" TEXT
	)'
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	@error = 'Something wrong'
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

post '/visit' do
	@username = params[:username]
	@phone = params[:phone]
	@date_time = params[:date_time]
	@barber = params[:barber]
	@color = params[:color]

	hh = {:username => 'Введите имя',
		:phone => 'Введите телефон',
		:date_time => 'Введите дату и время'}

	@error = hh.select{|key,_| params[key] == ""}.values.join(", ")

	if @error == '' 
		f = File.open("./public/users.txt", "a")
		f.write("Name: #{@username}, Phone: #{@phone}, Date/time: #{@date_time}, Barber: #{@barber}, Color: #{@color}.\n")
		f.close
		erb "Dear #{@username}, we will be waiting for you at #{@date_time}. Your barber is #{@barber}, Color: #{@color}. See you! <a href=\"http://localhost:4567\">На главную</a>"		
	else 
		return erb :visit
	end
end

post '/contacts' do

	@email = params["email"]
	@message = params["message"]

	hh = {:email => 'Введите Email',
		:message => 'Введите сообщение'}

	@error = hh.select{|key,_| params[key] == ""}.values.join(", ")
	
	if @error == '' 

		f = File.open("./public/contacts.txt", "a")
		f.write("Email: #{params[:email]}, Message: #{params[:message]}.\n")
		f.close

		Pony.mail(:to => 'sharaivladimir2@gmail.com', :from => @email, :body => @message,
			:via => :smtp,
  :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => 'sharaivladimir2@gmail.com',
    :password             => 'fyyfvjz1990',
    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain               => "localhost.localdomain"})

		erb "We will send our answer to #{params[:email]}. See you! <a href=\"http://localhost:4567\">На главную</a>"		
	else 
		return erb :contacts
	end
	end