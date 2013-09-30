
require 'rubygems'

require 'sinatra'

require 'coffee-script'

require 'pry'

set :server, %w[webrick thin mongrel]


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
  SYM = [:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o,:p]
  SIZES_START = [13,13,13,13,13,13,15,15,15,15,13,13,13,13,13,13]
  SEVENTEENS = [ [6,7], [6,8], [6,9], [7,8], [7,9], [8,9] ]
  TOP_BOTTOM = [0,1,2,3,4,5,10,11,12,13,14,15]
  CENTER_LANE = [6,7,8,9]
  ID_START = :a
  

  attr :pattern_string

  def initialize
    @grid = []
    @piece_sizes = shuffle_piece_sizes
    0.upto(9) do
      row = []
      24.times {|cc| row << :x}
      @grid << row
    end
    0.step(22,2) {|cx| @grid[9][cx] = :z} 

    fill_top_row
    fill_bottom_row
    fill_center_lane

  end


  def fill_top_row
    top = @piece_sizes[0..5]
    0.upto(5) {|n| build_top_piece(n,SYM[n],top[n]) }
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
    bottom = @piece_sizes[10..15]
    10.upto(15) {|n| build_bottom_piece(n,SYM[n],bottom[n-10]) }
  end


  def build_bottom_piece(n,sym,size)
    [1,3].each {|aa| set_hex(4*(n-10)+aa,9,sym)}
    [0,1,2,3].each {|aa| [8,7,6].each {|bb| set_hex(4*(n-10)+aa,bb,sym)} }
    if size == 13
      j = rand(2)
      set_hex(4*(n-10)+1+2*j,6,:x)
    end
    if size == 15
      k = rand(2)
      set_hex(4*(n-10)+2*k,5,sym)
    end
  end


  def fill_center_lane
    center = @piece_sizes[6..9]
    center_lane = []
    24.times {|cc| center_lane[cc] = []}
    @grid.each_index {|rr| @grid[rr].each_index {|cc| center_lane[cc] << rr if @grid[rr][cc] == :x} }
    6.upto(9) {|n| build_center_piece(n,SYM[n],center[n-6]) }
    center_lane.each_index { |cc| center_lane[cc].each {|rr| @grid[rr][cc] = :g} } # temp - for marking the center lane hexes
  end


  def build_center_piece(n,sym,size)
#    puts n
#    puts sym
#    puts size
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

