class PuzzleApp

  constructor: () ->

    @puzzle_view = new PuzzleView
    @piece = new PuzzlePiece
    @piece.draw_piece()



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
    @context.drawImage(@img,100,0)


#   #   #   #   #   #
#   Global Scope Statements
#   #   #   #   #   #


start = () ->
  @app = new PuzzleApp()


window.onload = start


