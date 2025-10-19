# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
enable :method_override

def load_data
  json_text = File.read('db.json')
  json_text = '{"last_id": 0, "memos": []}' if json_text.empty?
  JSON.parse(json_text, symbolize_names: true)
end

def save_data(record_data)
  File.open('db.json', 'w') { |file| file.write(JSON.generate(record_data)) }
end

def find_memo(id)
  memos_data = load_data
  memos_data[:memos].find { |memo| memo[:id] == id }
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# Top
get '/' do
  @memos_data = load_data

  erb :top
end

# New
get '/memos/new' do
  erb :new
end

post '/memos' do
  redirect '/memos/new' if params[:title].empty?

  memos_data = load_data
  id = memos_data[:last_id] += 1
  memo_data = params.slice(:title, :message).merge(id: id)
  memos_data[:memos] << memo_data

  save_data(memos_data)

  redirect '/'
end

# Show
get '/memos/:id' do
  @target_memo = find_memo(params[:id].to_i)

  erb :show
end

# Edit
get '/memos/:id/edit' do
  @target_memo = find_memo(params[:id].to_i)

  erb :edit
end

patch '/memos/:id' do
  memos_data = load_data
  edit_memo = memos_data[:memos].find { |memo| memo[:id] == params[:id].to_i }

  edit_memo[:title] = params[:title]
  edit_memo[:message] = params[:message]
  save_data(memos_data)

  redirect "memos/#{params[:id]}"
end

# Delete
get '/memos/:id/delete_confirmation' do
  @target_memo = find_memo(params[:id].to_i)

  erb :delete_confirmation
end

delete '/memos/:id' do
  memos_data = load_data
  memos_data[:memos].delete_if { |memo| memo[:id] == params[:id].to_i }
  save_data(memos_data)

  redirect '/'
end
