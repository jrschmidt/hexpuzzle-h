class PuzzleApp

  constructor: () ->

    @grid = new PuzzleGridModel
    @puzzle_view = new PuzzleView
    @piece = new PuzzlePiece(this)
    @piece.draw_piece(0,0)
    alert(":-)")
    @piece.draw_piece(2,1)
    alert(":-)")
    @piece.draw_piece(3,1)
    alert(":-)")
    @piece.draw_piece(2,3)
    alert(":-)")
    @piece.draw_piece(1,3)
    alert(":-)")
    @piece.draw_piece(4,3)
    alert(":-)")
    @piece.draw_piece(2,5)
    alert(":-)")
    @piece.draw_piece(2,6)
    alert(":-)")
    @piece.draw_piece(3,7)
    alert(":-)")
    @piece.draw_piece(5,4)
    alert(":-)")
    @piece.draw_piece(8,3)
    alert(":-)")
    @piece.draw_piece(8,1)
    alert(":-)")
    @piece.draw_piece(9,1)
    alert(":-)")
    @piece.draw_piece(10,1)
    alert(":-)")
    @piece.draw_piece(13,6)
    alert(":-)")
    @piece.draw_piece(18,4)
    alert(":-)")
    @piece.draw_piece(20,6)
    alert(":-)")
    @piece.draw_piece(21,2)
    alert(":-)")
    @piece.draw_piece(22,1)
    alert(":-)")
    @piece.draw_piece(22,4)



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
    @puzzle = puzzle_app
    @grid = @puzzle.grid
    @dxy = @get_piece_xy_offset()

  draw_piece:  (a,b) ->
    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")
    @pc_img = document.getElementById("piece")
    if @grid.in_range(a,b)
      xy = @grid.get_xy(a,b)
      @context.drawImage(@pc_img,xy[0]+@dxy[0],xy[1]+@dxy[1])
    else
      @context.drawImage(@pc_img,0,100)

  get_piece_xy_offset: () ->
    dx = -14 # (temporarily hard code these values)
    dy = 0
    dxy = [dx,dy]
    dxy



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


