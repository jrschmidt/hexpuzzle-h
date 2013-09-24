class PuzzleApp

  constructor: () ->

    @grid = new PuzzleGridModel
    @puzzle_view = new PuzzleView
    @piece = new PuzzlePiece(this)
    alert(":-)")
    @piece.draw_piece(0,0)
    alert(":-)")
    @piece.draw_piece(2,1)
    alert(":-)")
    @piece.draw_piece(6,4)
    alert(":-)")
    @piece.draw_piece(11,2)
    alert(":-)")
    @piece.draw_piece(20,1)
    alert(":-)")
    @piece.draw_piece(22,5)
    alert(":-)")
    @piece.draw_piece(19,6)
    alert(":-)")
    @piece.draw_piece(12,1)
    alert(":-)")
    @piece.draw_piece(3,6)
    alert(":-)")
    @piece.draw_piece(3,5)
    alert(":-)")
    @piece.draw_piece(3,4)
    alert(":-)")
    @piece.draw_piece(3,3)
    alert(":-)")
    @piece.draw_piece(3,2)
    alert(":-)")
    @piece.draw_piece(3,1)
    alert(":-)")
    @piece.draw_piece(2,1)
    alert(":-)")
    @piece.draw_piece(10,4)
    alert(":-)")
    @piece.draw_piece(16,3)
    alert(":-)")
    @piece.draw_piece(8,5)
    alert(":-)")
    @piece.draw_piece(2,1)



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



class PuzzleView

  constructor: () ->

    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")

    @img = document.getElementById("frame")
    @context.drawImage(@img,100,30)


#   #   #   #   #   #
#   Global Scope Statements
#   #   #   #   #   #


start = () ->
  @app = new PuzzleApp()


window.onload = start


