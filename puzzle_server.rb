
require 'rubygems'

require 'sinatra'

require 'coffee-script'

require 'pry'


get '/' do
  erb :index
end


get 'puzzle.js' do
  coffee :puzzle
end



class PuzzlePattern

  attr :pattern_string

#  def initialize
#    @pattern_string = ""
#    @grid = new PuzzleGrid
#  end


  def to_dom_string
    test_string = ""
    test_string << "aaaaabbbccccdddddeeeffff"
    test_string << "aaabbbbbccccdddeeeeeffff"
    test_string << "aaaabbbbccccddddeeeeffff"
    test_string << "aaaggbghhhhcdiddiiiejjjf"
    test_string << "ggggggghhhhhiiiiiiijjjjj"
    test_string << "gggglglghhhhiiiioiojjjjj"
    test_string << "kgkklllhmhmmninnooojpppj"
    test_string << "kkkklllllmmmmnnnoooopppp"
    test_string << "kkklklllmmmmnnnnooopoppp"
    test_string << "xkxkxlxmxmxnxnxnxoxoxpxp"
    test_string
  end

end



def puzzle_string
  @puzzle = PuzzlePattern.new
  @puzzle.to_dom_string
end
