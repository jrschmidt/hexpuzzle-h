class PuzzleApp

  constructor: () ->
    @grid_model = new PuzzleGridModel
    @puzzle_view = new PuzzleView
    @hex_draw = new HexDraw
    @pattern = new PuzzlePattern(this)
    @mask = new MissingPiecesMask(this,@pattern)
    @mask.draw_mask()

    @piece = new PuzzlePiece(this,@pattern)



class PuzzlePattern

  constructor: (puzzle_app) ->

    @puzzle = puzzle_app
    @hex_draw = @puzzle.hex_draw

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
    # FIXME the fill_hex methods are being refactored to take a context/image/canvas parameter telling it WHAT to draw on.
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
        @hex_draw.fillhex_ab(col,row,hue) unless (row==10 && col%2==1)



class MissingPiecesMask
  # TODO Add an Image object to this class. This way the puzzle piece image can
  # move around the widget, being drawn over the mask image in 'source-atop"
  # mode, so that the puzzle piece is only drawn over the mask image and nowhere
  # else. Probably want to add the 'staging area' to the opaque part of the mask
  # image, so that the piece can also be dragged across that region.

  constructor: (puzzle_app,puzzle_pattern) ->

    @puzzle = puzzle_app
    @pattern = puzzle_pattern
    @grid = @pattern.grid
    @hex_draw = @puzzle.hex_draw
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
        @hex_draw.fillhex_ab(aa,bb,0) if @grid[bb][aa] in @missing



class PuzzlePiece
  constructor: (puzzle_app,puzzle_pattern) ->

    @puzzle = puzzle_app
    @pattern = puzzle_pattern
    @grid = @pattern.grid
    @hexes = []

    @grid_model = @puzzle.grid_model

    @image = new PieceImage
    @redraw = new PieceRedrawBuffer

    @construct_piece("a")


  construct_piece: (sym) ->
    @sym = sym
    @hexes = @get_hexes()
    @box = new PieceRenderBox(this)
    @p_mask  = new PiecePattern(this)


  get_hexes: () ->
    hexes = []
    for bb in [1..10]
      for aa in [1..24]
        hexes.push([aa,bb]) if @grid[bb][aa] == @sym
    console.log("PIECE ID: "+@sym)
    console.log("    "+hx[0]+","+hx[1]) for hx in hexes
    hexes


  get_dim: () ->
    dim = [63,87] # (temporarily hard code these values)
    dim

  get_piece_xy_offset: () ->
    dx = -14 # (temporarily hard code these values)
    dy = 0
    dxy = [dx,dy]
    dxy



class PiecePattern

  constructor: (piece) ->
    @piece = piece
    @hexes = @piece.hexes
    @hex_draw = @piece.puzzle.hex_draw
    @img = document.createElement('canvas')
    @img.width = @piece.box.width
    @img.height = @piece.box.height
    @draw_pattern()


  draw_pattern: () ->
    for hx in @hexes
      aa = hx[0]
      bb = hx[1]
      @hex_draw.fillhex_ab_xy(aa,bb,10,100,3)



class PieceImage

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



class PieceRedrawBuffer
# TODO Set a height delta of 10px if anchor hex column is odd.

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

#    @dim = @get_dim()
#    @width = @dim[0]
#    @height = @dim[1]
#    @redraw.reset_size(@width,@height)

#    dxy = @get_piece_xy_offset()
#    @dx = dxy[0]
#    @dy = dxy[1]



class PieceRenderBox

  constructor: (piece) ->

    @piece = piece
    @hexes = @piece.hexes
    left = 30
    right = 0
    top = 100
    bottom = 0
    hx_top = 12
    hx_bottom = 0

    for hx in @hexes
      aa = hx[0]
      bb = hx[1]
      b = 5 + 10*(bb-1) + 5*(aa%2)
      left = aa if aa < left
      right = aa if aa > right
      if b < top
        top = b
        hx_top = bb
      if b > bottom
        bottom = b
        hx_bottom = bb

    hx_left = left
    hx_right = right
    @anchor_hex = [hx_left,hx_top]
    @hex_width = hx_right - hx_left + 1
    @hex_height = hx_bottom - hx_top + 1

    cols = right - left + 1
    halves = (bottom - top)/5 + 2
    @width = 6 + cols*14
    @height = halves*10

    console.log("PieceRenderBox:")
    console.log("    cols = "+cols)
    console.log("    halves = "+halves)
    console.log("    WIDTH = "+@width)
    console.log("    HEIGHT = "+@height)
    console.log("    ANCHOR HEX = "+@anchor_hex[0]+","+@anchor_hex[1])



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



class HexDraw

  constructor: () ->
    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")
    @colors = ["#cc5050","#5050cc","#50cccc","#50cc50","#cccc50","#cc50cc","#000000"]


  fillhex_ab: (a,b,c_no) ->
    x = 113+a*14
    y = 27+b*20
    y = y-9 if (a%2 == 0)
    @fillhex_xy(x,y,c_no)


  fillhex_ab_xy: (a,b,x,y,c_no) ->  # {temp method ???}
    xx = x+(a-1)*14
    yy = y+(b-1)*20
    yy = yy-9 if (a%2 == 0)
    @fillhex_xy(xx,yy,c_no)


  # TODO Change this to draw on any image (like PieceMask)
  fillhex_xy: (x,y,c_no) ->
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



#   #   #   #   #   #
#   Global Scope Statements
#   #   #   #   #   #


start = () ->
  @app = new PuzzleApp()


window.onload = start


