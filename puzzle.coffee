class PuzzleApp

  constructor: () ->

    @grid = new PuzzleGridModel
    @puzzle_view = new PuzzleView
    @piece = new PuzzlePiece
    @piece.draw_piece()



class PuzzleGridModel

  in_range: (a,b) ->
    a = 0 if not a?
    b = 0 if not b?
    ok = true
    ok = false if a<1 || a>24
    ok = false if b<1 || b>10
    ok = false if b == 10 && a%2 == 1
    ok



class PuzzlePiece

  draw_piece:  () ->
    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")
    @pc_img = document.getElementById("piece")
    @context.drawImage(@pc_img,0,100)



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


