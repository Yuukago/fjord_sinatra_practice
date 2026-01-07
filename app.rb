# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
enable :method_override

def db
  PG.connect(dbname: 'memos')
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  conn = db
  @memos = conn.exec('SELECT * FROM memo')

  erb :top
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  redirect '/memos/new' if params[:title].empty?

  conn = db
  conn.exec_params('INSERT INTO memo (title, message) VALUES ($1, $2)', [params[:title], params[:message]])

  redirect '/'
end

get '/memos/:id' do
  conn = db
  @memo = conn.exec_params('SELECT * FROM memo WHERE memo_id = $1', [params[:id]]).to_a.first

  erb :show
end

get '/memos/:id/edit' do
  conn = db
  @memo = conn.exec_params('SELECT * FROM memo WHERE memo_id = $1', [params[:id]]).to_a.first

  erb :edit
end

patch '/memos/:id' do
  conn = db
  conn.exec_params('UPDATE memo SET title = $1, message = $2 WHERE memo_id = $3', [params[:title], params[:message], params[:id]])

  redirect "memos/#{params[:id]}"
end

get '/memos/:id/delete_confirmation' do
  conn = db
  @memo = conn.exec_params('SELECT * FROM memo WHERE memo_id = $1', [params[:id]]).to_a.first

  erb :delete_confirmation
end

delete '/memos/:id' do
  conn = db
  conn.exec_params('DELETE FROM memo WHERE memo_id = $1', [params[:id]])

  redirect '/'
end
