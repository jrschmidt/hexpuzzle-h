
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
  TOP = [:a,:b,:c,:d,:e,:f]
  BOTTOM = [:k,:l,:m,:n,:o,:p]
  CENTER = [:g,:h,:i,:j]
  SIZES_START = [13,13,13,13,13,13,15,15,15,15,13,13,13,13,13,13]
  SEVENTEENS = [ [6,7], [6,8], [6,9], [7,8], [7,9], [8,9] ]
  TOP_BOTTOM = [0,1,2,3,4,5,10,11,12,13,14,15]
  CENTER_LANE = [6,7,8,9]
  ID_START = :a
  

  attr :pattern_string

  def initialize
    @grid = []
    @piece_sizes = shuffle_piece_sizes

    # TODO When we 'switch on" the live hex fill function, we will need to
    #      initialize each hex to :empty.
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
    0.upto(9) do
      row = []
      24.times {|cc| row << :x}
      @grid << row
#      str = test[rr]
#      row = []
#      0.upto(str.size-1) {|cc| row << str[cc].to_sym}
#      @grid << row
    end

    fill_top_row
    fill_bottom_row
    fill_center_lane

  end


  def fill_top_row
    top = @piece_sizes[0..5]
    0.upto(5) {|n| build_top_piece(n,TOP[n],top[n]) }
  end


  def build_top_piece(n,sym,size)
    [0,1,2,3].each {|aa| [0,1,2].each {|bb| set_hex(4*n+aa,bb,sym)} }
    if size == 13
      j = rand(2)
      set_hex(4*n+1+2*j,3,sym)
    end
    if size == 15
      k = rand(4)
      4.times {|i| set_hex(4*n+i,3,sym) unless i == k}
    end
  end


  def fill_bottom_row

  end


  def fill_center_lane

  end


  def shuffle_piece_sizes
    sizes = SIZES_START

    # Top & bottom rows
    fifteens = 0
    until fifteens == 4 do
      r6 = rand(6)
      if not (sizes[r6] == 15 || sizes[r6+10] == 15)
        r2 = rand(2)
        sizes[r6+10*r2] = 15
        fifteens = fifteens+1      
      end
    end    

    # Center lane
    r6 = rand(6)
    p17 = SEVENTEENS[r6]
    p17.each {|i| sizes[i] = 17}
    sizes
  end


  def set_hex(aa,bb,sym)
    @grid[bb][aa] = sym
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

