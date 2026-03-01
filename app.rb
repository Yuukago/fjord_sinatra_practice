# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
enable :method_override

DB = PG.connect(dbname: 'memos')

def find_memo
  DB.exec_params('SELECT * FROM memo WHERE memo_id = $1', [params[:id]]).first
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @memos = DB.exec('SELECT * FROM memo ORDER BY memo_id DESC')

  erb :top
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  redirect '/memos/new' if params[:title].empty?
  DB.exec_params('INSERT INTO memo (title, message) VALUES ($1, $2)', [params[:title], params[:message]])

  redirect '/'
end

get '/memos/:id' do
  @memo = find_memo

  erb :show
end

get '/memos/:id/edit' do
  @memo = find_memo

  erb :edit
end

patch '/memos/:id' do
  DB.exec_params('UPDATE memo SET title = $1, message = $2 WHERE memo_id = $3', [params[:title], params[:message], params[:id]])

  redirect "memos/#{params[:id]}"
end

get '/memos/:id/delete_confirmation' do
  @memo = find_memo

  erb :delete_confirmation
end

delete '/memos/:id' do
  DB.exec_params('DELETE FROM memo WHERE memo_id = $1', [params[:id]])

  redirect '/'
end
