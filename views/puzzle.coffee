class PuzzleApp

  constructor: () ->

    @grid = new PuzzleGridModel
    @puzzle_view = new PuzzleView
    @hx = new HexBuilder
    @hx_data = new HexTestData(@hx)

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



class HexTestData

  constructor: (hx_builder) ->

    @hex = hx_builder
    @canvas = document.getElementById("puzzle-widget")
    dstring = @canvas.getAttribute("data-puzzle-pattern")
    n = 0
    for row in [1..10]
      for col in [1..24]
          ch = dstring[n]
          n = n+1
          console.log(col+","+row+"  ch["+n+"] = "+ch)
          switch ch
            when "b","f","n" then hue = 0
            when "a","e","m" then hue = 1
            when "g","i" then hue = 2
            when "c","k","o" then hue = 3
            when "d","l","p" then hue = 4
            when "h","j" then hue = 5
            when "x" then hue = 6
          @hex.fillhex(col,row,hue) unless (row==10 && col%2==1)



class PuzzleView

  constructor: () ->

    @backgrounds = ["#cc5050","#80cc50","#50b4cc",
                    "#b450cc","#cc8050","#50cc50",
                    "#5080cc","#cc50b4","#ccb450",
                    "#50cc80","#5050cc","#cc5080",
                    "#b4cc50","#50ccb4","#8050cc"]

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


