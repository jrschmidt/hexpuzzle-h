class PuzzleApp

  constructor: () ->

    @grid = new PuzzleGridModel
    @puzzle_view = new PuzzleView
    @hx = new HexBuilder

    @piece = new PuzzlePiece(this)



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

  constructor: (puzzle_app) ->

    # TODO When we code movement of the puzzle piece across the grid, we will
    #      extract these lines to a 'reset(a,b)' method.
    #         (which lines?)

    @dim = @get_dim()
    @width = @dim[0]
    @height = @dim[1]

    @redraw = document.createElement('canvas')
    @redraw.width = @width
    @redraw.height = @height

    @redraw_x = 0
    @redraw_y = 0
    @redraw_active = false

    @puzzle = puzzle_app
    @grid = @puzzle.grid

    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")

    dxy = @get_piece_xy_offset()
    @dx = dxy[0]
    @dy = dxy[1]


    # FIXME 'index out of range' error for ctx.drawImage with jasmine, but
    #       okay for standalone. Possibly image loading issues.
    # TODO  After we get this working correctly, change name to set_piece and
    #       make seperate methods for draw_piece, set_redraw, redraw, etc.
  draw_piece:  (a,b) ->
    @pc_img = document.getElementById("piece")
    if @grid.in_range(a,b)
      xy = @grid.get_xy(a,b)
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



class RedrawBuffer

  constructor: () ->
    @buffer = document.createElement('canvas')
    @width = 1
    @height = 1

  reset_size: (x,y) ->
    @width = x
    @height = y



class HexBuilder

  constructor: () ->
    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")
    @colors = ["#cc5050","#5050cc","#50cccc","#50cc50","#cccc50","#cc50cc"]

    @fillhex(1,1,1)
    @fillhex(1,2,0)
    @fillhex(2,1,3)
    @fillhex(2,2,4)
    @fillhex(3,1,5)
    @fillhex(3,2,0)


  fillhex: (a,b,c_no) ->
    x = 106+a*14
    y = 35+b*20
    y = y+9 if (a%2 == 0)
    @context.fillStyle = @colors[c_no]
    @context.beginPath()
    @context.moveTo(x,y)
    @context.lineTo(x+9,y)
    @context.lineTo(x+14,y+9)
    @context.lineTo(x+9,y+19)
    @context.lineTo(x,y+19)
    @context.lineTo(x-5,y+9)
    @context.lineTo(x,y)
    @context.fill()
    @context.closePath()



class PuzzleView

  constructor: () ->

    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")

#    @img = document.getElementById("frame")
#    @context.drawImage(@img,100,30)


#   #   #   #   #   #
#   Global Scope Statements
#   #   #   #   #   #


start = () ->
  @app = new PuzzleApp()


window.onload = start


