# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
enable :method_override

def load_data
  json_text = File.read('db.json')
  json_text.empty? ? { last_id: 0, memos: [] } : JSON.parse(json_text, symbolize_names: true)
end

def save_data(record_data)
  File.open('db.json', 'w') { |file| file.write(JSON.generate(record_data)) }
end

def find_memo(id)
  memos = load_data
  memos[:memos].find { |memo| memo[:id] == id }
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# Top
get '/' do
  @memos = load_data

  erb :top
end

# New
get '/memos/new' do
  erb :new
end

post '/memos' do
  redirect '/memos/new' if params[:title].empty?

  memos = load_data
  id = memos[:last_id] += 1
  memo = params.slice(:title, :message).merge(id:)
  memos[:memos] << memo

  save_data(memos)

  redirect '/'
end

# Show
get '/memos/:id' do
  @memo = find_memo(params[:id].to_i)

  erb :show
end

# Edit
get '/memos/:id/edit' do
  @memo = find_memo(params[:id].to_i)

  erb :edit
end

patch '/memos/:id' do
  memos = load_data
  edit_memo = memos[:memos].find { |memo| memo[:id] == params[:id].to_i }

  edit_memo[:title] = params[:title]
  edit_memo[:message] = params[:message]
  save_data(memos)

  redirect "memos/#{params[:id]}"
end

# Delete
get '/memos/:id/delete_confirmation' do
  @memo = find_memo(params[:id].to_i)

  erb :delete_confirmation
end

delete '/memos/:id' do
  memos = load_data
  memos[:memos].delete_if { |memo| memo[:id] == params[:id].to_i }
  save_data(memos)

  redirect '/'
end
