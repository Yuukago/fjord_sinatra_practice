# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
enable :method_override

def load_data
  json_text = File.read('db.json')
  json_text = "{'last_id': 0, 'memos': []}" if json_text.empty?
  JSON.parse(json_text)
end

def save_data(record_data)
  File.open('db.json', 'w') { |file| file.write(JSON.generate(record_data)) }
end

def display_memo(id_number)
  data_converted_to_ruby = load_data
  data_converted_to_ruby['memos'].find { |memo| memo['id'] == id_number }
end

# Top
get '/' do
  data_converted_to_ruby = load_data
  id_and_title = data_converted_to_ruby['memos'].map do |data|
    [data['id'], data['title']]
  end
  @list = id_and_title.map { |memo| "<li><a href='/#{memo[0]}'>#{memo[1]}</a></li>" }.join

  erb :top
end

# New
get '/new' do
  erb :new
end

post '/new' do
  redirect '/new' if params['title'].empty?

  data_converted_to_ruby = load_data
  id = data_converted_to_ruby['last_id'] += 1
  title = params['title']
  message = params['message']
  data_converted_to_ruby['memos'] << { 'id' => id, 'title' => title, 'message' => message }

  save_data(data_converted_to_ruby)

  redirect '/'
end

# Show
get '/:id' do
  @display_memo = display_memo(params['id'].to_i)

  erb :show
end

# Edit
get '/:id/edit' do
  @display_memo = display_memo(params['id'].to_i)

  erb :edit
end

patch '/:id/edit' do
  data_converted_to_ruby = load_data
  edit_memo = data_converted_to_ruby['memos'].find { |memo| memo['id'] == params['id'].to_i }

  edit_memo['title'] = params['title']
  edit_memo['message'] = params['message']
  save_data(data_converted_to_ruby)

  redirect "/#{params['id']}"
end

# Delete
get '/:id/delete' do
  @display_memo = display_memo(params[:id].to_i)

  erb :delete
end

delete '/:id/delete' do
  data_converted_to_ruby = load_data
  data_converted_to_ruby['memos'].delete_if { |memo| memo['id'] == params['id'].to_i }
  save_data(data_converted_to_ruby)

  redirect '/'
end
