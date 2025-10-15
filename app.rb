# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
enable :method_override

def load_data
  json_text = File.read('db.json')
  json_text = '{"last_id": 0, "memos": []}' if json_text.empty?
  JSON.parse(json_text)
end

def save_data(record_data)
  File.open('db.json', 'w') { |file| file.write(JSON.generate(record_data)) }
end

def find_memo(id)
  data_converted_to_ruby = load_data
  data_converted_to_ruby['memos'].find { |memo| memo['id'] == id }
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# Top
get '/' do
  @data_converted_to_ruby = load_data

  erb :top
end

# New
get '/memos/new' do
  erb :new
end

post '/memos' do
  redirect '/memos/new' if params['title'].empty?

  data_converted_to_ruby = load_data
  id = data_converted_to_ruby['last_id'] += 1
  title = params['title']
  message = params['message']
  data_converted_to_ruby['memos'] << { 'id' => id, 'title' => title, 'message' => message }

  save_data(data_converted_to_ruby)

  redirect '/'
end

# Show
get '/memos/:id' do
  @target_memo = find_memo(params['id'].to_i)

  erb :show
end

# Edit
get '/memos/:id/edit' do
  @target_memo = find_memo(params['id'].to_i)

  erb :edit
end

patch '/memos/:id' do
  data_converted_to_ruby = load_data
  edit_memo = data_converted_to_ruby['memos'].find { |memo| memo['id'] == params['id'].to_i }

  edit_memo['title'] = params['title']
  edit_memo['message'] = params['message']
  save_data(data_converted_to_ruby)

  redirect "memos/#{params['id']}"
end

# Delete
get '/memos/:id/delete_confirmation' do
  @target_memo = find_memo(params[:id].to_i)

  erb :delete_confirmation
end

delete '/memos/:id' do
  data_converted_to_ruby = load_data
  data_converted_to_ruby['memos'].delete_if { |memo| memo['id'] == params['id'].to_i }
  save_data(data_converted_to_ruby)

  redirect '/'
end
