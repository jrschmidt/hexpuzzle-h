class PuzzleApp

  constructor: () ->
    @grid_model = new PuzzleGridModel
    @puzzle_view = new PuzzleView
    @hex = new HexBuilder
    @pattern = new PuzzlePattern(this)
    @mask = new MissingPiecesMask(this,@pattern)
    @mask.draw_mask()

    @piece = new PuzzlePiece(this,@pattern)


class PuzzleGridModel

  get_xy: (a,b) ->
    if @in_range(a,b)
      t_dx = -3 # (temporary offsets for development)
      t_dy = -2
      x = 103 + 14.5*a + (a%2)/2 + t_dx
      y = 28 + 19*b + (a%2)*10 + t_dy
      xy = [x,y]
    else
      xy = [0,0]
    xy


  in_range: (a,b) ->
    a = 0 if not a?
    b = 0 if not b?
    ok = true
    ok = false if a<1 || a>24
    ok = false if b<1 || b>10
    ok = false if b == 10 && a%2 == 1
    ok



class PuzzlePiece
  constructor: (puzzle_app,puzzle_pattern) ->

    @puzzle = puzzle_app
    @pattern = puzzle_pattern
    @grid = @pattern.grid
    @hexes = []

    @grid_model = @puzzle.grid_model

    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")
    @redraw = new RedrawBuffer

    @construct_piece("a")

  construct_piece: (sym) ->
    @sym = sym
    @hexes = @get_hexes()
    @box = new PieceRenderBox(this)


  get_hexes: () ->
    hexes = []
    for bb in [1..10]
      for aa in [1..24]
        hexes.push([aa,bb]) if @grid[bb][aa] == @sym
    console.log("PIECE ID: "+@sym)
    console.log("    "+hx[0]+","+hx[1]) for hx in hexes
    hexes


#    @dim = @get_dim()
#    @width = @dim[0]
#    @height = @dim[1]
#    @redraw.reset_size(@width,@height)

#    dxy = @get_piece_xy_offset()
#    @dx = dxy[0]
#    @dy = dxy[1]


  draw_piece:  (a,b) ->
    @pc_img = document.getElementById("piece")
    if @grid_model.in_range(a,b)
      xy = @grid_model.get_xy(a,b)
      xx = xy[0]+@dx
      yy = xy[1]+@dy

      @context.drawImage(@redraw,@redraw_x,@redraw_y) if @redraw_active
      ctx = @redraw.getContext('2d')
      ctx.drawImage(@canvas,xx,yy,@width,@height,0,0,@width,@height)
      @redraw_active = true
      @redraw_x = xx
      @redraw_y =yy

      @context.drawImage(@pc_img,xx,yy)
    else
      @context.drawImage(@pc_img,0,100)

  get_dim: () ->
    dim = [63,87] # (temporarily hard code these values)
    dim

  get_piece_xy_offset: () ->
    dx = -14 # (temporarily hard code these values)
    dy = 0
    dxy = [dx,dy]
    dxy



class PieceRenderBox

  constructor: (piece) ->

    @piece = piece
    @hexes = @piece.hexes
    left = 30
    right = 0
    top = 100
    bottom = 0
    for hx in @hexes
      a = hx[0]
      bb = hx[1]
      b = 5 + 10*(bb-1) + 5*(a%2)
      left = a if a < left
      right = a if a > right
      top = b if b < top
      bottom = b if b > bottom
    cols = right - left + 1
    halves = (bottom - top)/5 + 2
    @width = 6 + cols*14
    @height = halves*10
    console.log("PieceRenderBox:")
    console.log("    cols = "+cols)
    console.log("    halves = "+halves)
    console.log("    WIDTH = "+@width)
    console.log("    HEIGHT = "+@height)



class RedrawBuffer

  constructor: () ->
    @redraw = document.createElement('canvas')

    @redraw.width = @width
    @redraw.height = @height

    @redraw_x = 0
    @redraw_y = 0
    @redraw_active = false

  reset_size: (x,y) ->
    @width = x
    @height = y



class HexBuilder

  constructor: () ->
    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")
    @colors = ["#cc5050","#5050cc","#50cccc","#50cc50","#cccc50","#cc50cc","#000000"]


  fillhex: (a,b,c_no) ->
    x = 113+a*14
    y = 27+b*20
    y = y-9 if (a%2 == 0)
    @context.fillStyle = @colors[c_no]
    @context.beginPath()
    @context.moveTo(x,y)
    @context.lineTo(x+10,y)
    @context.lineTo(x+15,y+11)
    @context.lineTo(x+10,y+20)
    @context.lineTo(x-1,y+20)
    @context.lineTo(x-6,y+10)
    @context.lineTo(x,y)
    @context.fill()
    @context.closePath()



class PuzzlePattern

  constructor: (puzzle_app) ->

    @puzzle = puzzle_app
    @hex = @puzzle.hex # [(temp) use this object to draw pattern on canvas]

    @canvas = document.getElementById("puzzle-widget")
    @dstring = @canvas.getAttribute("data-puzzle-pattern")

    @grid = @get_pattern_grid(@dstring)


  get_pattern_grid: (data_string) ->
    grid = []
    n = 0
    for row in [1..10]
      grid[row] = []
      for col in [1..24]
        ch = @dstring[n]
        grid[row][col] = ch
        n = n+1
    console.log(rrow) for rrow in grid
    grid


  draw_pattern: () -> # [(temp) - test/diagnostic method]
    n = 0
    for row in [1..10]
      for col in [1..24]
        ch = @dstring[n]
        n = n+1
        switch ch
          when "b","f","n" then hue = 0
          when "a","e","m" then hue = 1
          when "g","i" then hue = 2
          when "c","k","o" then hue = 3
          when "d","l","p" then hue = 4
          when "h","j" then hue = 5
          when "x" then hue = 6
        @hex.fillhex(col,row,hue) unless (row==10 && col%2==1)



class MissingPiecesMask

  constructor: (puzzle_app,puzzle_pattern) ->

    @puzzle = puzzle_app
    @pattern = puzzle_pattern
    @grid = @pattern.grid
    @hex = @puzzle.hex
    @missing = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]

    # ------[(temp) test data generator]------
    take = Math.floor(24*Math.random())
    for i in [1..take]
      next = Math.floor(24*Math.random())
      delete @missing[next]
    # ------[(temp) test data generator]------

    @draw_mask()


  draw_mask: () ->
    for bb in [1..10]
      for aa in [1..24]
        @hex.fillhex(aa,bb,0) if @grid[bb][aa] in @missing




class PuzzleView

  constructor: () ->

    @backgrounds = ["#cc5050","#80cc50","#50b4cc",
                    "#b450cc","#cc8050","#50cc50",
                    "#5080cc","#cc50b4","#ccb450",
                    "#50cc80","#5050cc","#cc5080",
                    "#b4cc50","#50ccb4","#8050cc"]
    @mask_color = @backgrounds[0] # FIXME (temporarily using same color without rotating)

    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")

    @img = document.getElementById("photo")
    @context.drawImage(@img,100,30)


#   #   #   #   #   #
#   Global Scope Statements
#   #   #   #   #   #


start = () ->
  @app = new PuzzleApp()


window.onload = start


