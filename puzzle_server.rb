
require 'rubygems'

require 'sinatra'

require 'coffee-script'

require 'pry'


get '/' do
  erb :index
end


get '/javascripts/puzzle.js' do
  coffee :puzzle
end



class PuzzlePattern

  TOP_BOTTOM_PIECES = 6
  MID_ROW_PIECES = 4
  VERT_LANE_WIDTH = 4

  ID_START = :a
  

  attr :pattern_string

  def initialize
    @grid = []
#    shuffle_piece_sizes
#    fill_top_row
#    fill_bottom_row
#    fill_center_lane

    test = []
    test << "aaaaabbbccccdddddeeeffff"
    test << "aaabbbbbccccdddeeeeeffff"
    test << "aaaabbbbccccddddeeeeffff"
    test << "aaaggbghhhhcdiddiiiejjjf"
    test << "ggggggghhhhhiiiiiiijjjjj"
    test << "gggglglghhhhiiiioiojjjjj"
    test << "kgkklllhmhmmninnooojpppj"
    test << "kkkklllllmmmmnnnoooopppp"
    test << "kkklklllmmmmnnnnooopoppp"
    test << "xkxkxlxmxmxnxnxnxoxoxpxp"
    0.upto(9) do |rr|
      str = test[rr]
      row = []
      0.upto(str.size-1) {|cc| row << str[cc].to_sym}
      @grid << row
    end 
  end


  def fill_top_row

  end


  def fill_bottom_row

  end


  def fill_center_lane

  end


  def shuffle_piece_sizes

  end


  def to_dom_string
    str = ""
    @grid.each {|row| row.each {|hx| str << hx.to_s} }
    str
  end

end



def puzzle_string
  @puzzle = PuzzlePattern.new
  @puzzle.to_dom_string
end

