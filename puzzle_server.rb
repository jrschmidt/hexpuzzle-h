
require 'rubygems'

require 'sinatra'

require 'coffee-script'

require 'json'

require 'pry'

set :server, %w[webrick thin mongrel]

set :port, 4566


before '/' do
  @pj = PuzzleJson.new
end


get '/' do
  erb :index
end


get '/javascripts/puzzle.js' do
  coffee :puzzle
end


get '/puzzle-pattern' do
  @puzzle = PuzzlePattern.new
  pz = @puzzle.to_puzzle_string
  pz_obj = {pstring: pz}
  return pz_obj.to_json
end


get '/pz-photo' do
  send_file @photo_name, :filename => @photo_name, :type => :png
end
