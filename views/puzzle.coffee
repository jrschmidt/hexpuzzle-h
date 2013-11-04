class PuzzleApp

  constructor: () ->
    @puzzle_view = new PuzzleView(this)
    @grid_model = new PuzzleGridModel
    @hex_grid = new HexGrid(this)
    @hex_draw = new HexDraw(this)

    @hex_box = new HexBox(this)

    @events = new EventHandler(this)

    @pattern = new PuzzlePattern(this)
#    @mask = new MissingPiecesMask(this)
#    @piece = new PuzzlePiece(this)

#    @pattern.draw_pattern()
#    @piece.construct_piece("e")
#    @piece.draw_piece(0,0)

#    @piece.draw_piece_ab(@piece.box.anchor_hex[0],@piece.box.anchor_hex[1])

    @hex_box.set_hex_box("f")

    @hex_draw.draw_all_hexes()

#    @pixel_test = new PixelHexTester(this)
#    @pixel_test.mark_hex_centerpoints()
#    @pixel_test.test(100000)



class PixelHexTester


  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @grid_model = @puzzle.grid_model
    @xx = 120
    @yy = 30
    @wd = 350
    @ht = 220


  test: (n) ->
    for k in [0..n]
      @pixel_test()


  pixel_test: () ->
    x = @xx + Math.floor(@wd*Math.random())
    y = @yy + Math.floor(@ht*Math.random())
    @dot(x,y)


  mark_hex_centerpoints: () ->
    for aa in [1..24]
      for bb in [1..10]
        if not (aa%2 == 1 and bb == 10)
          corner = @grid_model.get_xy(aa,bb)
          @put_dot(corner[0],corner[1],"#666666")
          ctr_x = corner[0]+9
          ctr_y = corner[1]+10
          @put_dot(ctr_x,ctr_y,"#ff0000")


  dot: (x,y) ->
    hex = @grid_model.get_hex(x,y)

#    if hex[0] in [6,7,8] and hex[1] in [3,4,5]
    if hex[0] > 0 and hex[0] < 25 and hex[1] > 0 and hex[1] < 11
      color = @get_dot_color(hex)
      @put_dot(x,y,color)


  put_dot: (x,y,color) ->
    canvas = document.getElementById("puzzle-widget")
    context = canvas.getContext('2d')
    context.fillStyle = color
    context.fillRect(x,y,1,1)
#    console.log(@color_name(color)+" dot at "+x+","+y)


  color_name: (cc) ->
    cc = "   red" if cc == "#ff0000"
    cc = " green" if cc == "#00ff00"
    cc = "yellow" if cc == "#ffff00"
    cc


  get_dot_color: (hex) ->
    color = "#00ff00" if hex[0] % 2 == 0 and hex[1] % 3 == 0
    color = "#ff0000" if hex[0] % 2 == 0 and hex[1] % 3 == 1
    color = "#ffff00" if hex[0] % 2 == 0 and hex[1] % 3 == 2
    color = "#ffff00" if hex[0] % 2 == 1 and hex[1] % 3 == 0
    color = "#00ff00" if hex[0] % 2 == 1 and hex[1] % 3 == 1
    color = "#ff0000" if hex[0] % 2 == 1 and hex[1] % 3 == 2
    color



class EventHandler

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @grid_model = @puzzle.grid_model


  click_handle: (e) ->
    @canvas = document.getElementById("puzzle-widget")
    dx = @canvas.offsetLeft
    dy = @canvas.offsetTop
    px = e.pageX
    py = e.pageY
    x = px-dx
    y = py-dy

    console.log("mouse click: "+x+","+y)
    hex = @grid_model.get_hex(x,y)
    console.log("A*,B* ~= "+hex[0]+","+hex[1])



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
    @hex_draw.set_context("canvas")
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
        @hex_draw.fill_hex_ab(col,row,hue) unless (row==10 && col%2==1)



class MissingPiecesMask
  # TODO Add an Image object to this class. This way the puzzle piece image can
  # move around the widget, being drawn over the mask image in 'source-atop"
  # mode, so that the puzzle piece is only drawn over the mask image and nowhere
  # else. Probably want to add the 'staging area' to the opaque part of the mask
  # image, so that the piece can also be dragged across that region.

  constructor: (puzzle_app) ->

    @puzzle = puzzle_app
    @pattern = @puzzle.pattern
    @grid = @pattern.grid
    @hex_draw = @puzzle.hex_draw
    @missing = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]

    # ------[(temp) test data generator]------
    take = Math.floor(24*Math.random())
    for i in [1..take]
      next = Math.floor(24*Math.random())
      delete @missing[next]
    # ------[(temp) test data generator]------

#    @draw_mask()


  draw_mask: () ->
    @hex_draw.set_context("canvas")
    for bb in [1..10]
      for aa in [1..24]
        @hex_draw.fill_hex_ab(aa,bb,0) if @grid[bb][aa] in @missing



class PuzzlePiece
  constructor: (puzzle_app) ->

    @puzzle = puzzle_app
    @hexes = []

    @grid_model = @puzzle.grid_model

    @box = new PieceRenderBox(this)
    @p_mask  = new PiecePattern(this)
    @redraw = new PieceRedrawBuffer


  construct_piece: (sym) ->
    @sym = sym
    @hexes = @get_hexes()
    @box.set_box_dimensions()
    @p_mask.draw_pattern()
    @draw_piece(0,100)
    @cut_piece_from_photo()

  cut_piece_from_photo: () ->

    @photo_clip = document.createElement('canvas')
    @photo_clip.id = "photo-clip"
    @photo_clip.width = @box.width
    @photo_clip.height = @box.height
    @photo_clip_context = @photo_clip.getContext('2d')
    @photo_clip_context.drawImage(@puzzle.puzzle_view.img,@box.box_xy[0],@box.box_xy[1],@box.width,@box.height,0,0,@box.width,@box.height)

    view_context = @puzzle.puzzle_view.context_canvas
    view_context.drawImage(@photo_clip,0,190)

    context = @p_mask.piece_mask_context
    context.globalCompositeOperation = 'source-atop'
    context.drawImage(@photo_clip,0,0)
    context.globalCompositeOperation = 'source-over'


  draw_piece_ab: (a,b) ->

    b = b-1 if a%2 == 0 and @box.anchor_hex[0] % 2 == 1
    x = 107+a*14
    y = 18+b*20
    y = y+9 if @box.high_hex_adjust
    y = y+9 if Math.abs(@box.anchor_hex[0] - a) % 2 == 1
    @draw_piece(x,y)


  draw_piece: (x,y) ->
    context = @puzzle.puzzle_view.context_canvas
    context.drawImage(@p_mask.img,x,y)


  # TODO Does this method belong in PuzzlePattern class?
  get_hexes: () ->
    hexes = []
    for bb in [1..10]
      for aa in [1..24]
        hexes.push([aa,bb]) if @puzzle.pattern.grid[bb][aa] == @sym
    console.log("PIECE ID: "+@sym)
    console.log("    "+hx[0]+","+hx[1]) for hx in hexes
    hexes


#  FIXME (Used by the deprecated redraw method)
#  get_dim: () ->
#    dim = [63,87] # (temporarily hard code these values)
#    dim

#  get_piece_xy_offset: () ->
#    dx = -14 # (temporarily hard code these values)
#    dy = 0
#    dxy = [dx,dy]
#    dxy



class PiecePattern

  constructor: (piece) ->
    @piece = piece
    @hex_draw = @piece.puzzle.hex_draw
    @img = document.createElement('canvas')
    @img.id = "piece-mask"
    @piece_mask_context = @img.getContext('2d')


  draw_pattern: () ->
    @img.width = @piece.box.width
    @img.height = @piece.box.height
    @hexes = @piece.hexes
    @hex_draw.set_context("piece_mask")
    xx = 6
    if @piece.box.high_hex_adjust == true then hx_adjust = -9 else hx_adjust = 0
    for hx in @hexes
      aa = hx[0] - @piece.box.anchor_hex[0] + 1
      bb = hx[1] - @piece.box.anchor_hex[1] + 1

      if @piece.box.anchor_hex[0] % 2 == 1
        yy = 9
      else
        if hx[0]%2 == 1
          yy = 18
        else
          yy = 0
      yy = yy + hx_adjust
      @fill_hex_ab_xy(aa,bb,xx,yy,3)


  fill_hex_ab_xy: (a,b,x,y,c_no) ->
    xx = x+(a-1)*14
    yy = y+(b-1)*20
    yy = yy-9 if (a%2 == 0)
    @hex_draw.fill_hex_xy(xx,yy,c_no)


## FIXME Saving this method from a discontinued class as an example because the redraw works correctly.
#  draw_piece:  (a,b) ->
#    @pc_img = document.getElementById("piece")
#    if @grid_model.in_range(a,b)
#      xy = @grid_model.get_xy(a,b)
#      xx = xy[0]+@dx
#      yy = xy[1]+@dy

#      @context.drawImage(@redraw,@redraw_x,@redraw_y) if @redraw_active
#      ctx = @redraw.getContext('2d')
#      ctx.drawImage(@canvas,xx,yy,@width,@height,0,0,@width,@height)
#      @redraw_active = true
#      @redraw_x = xx
#      @redraw_y =yy

#      @context.drawImage(@pc_img,xx,yy)
#    else
#      @context.drawImage(@pc_img,0,100)



class PieceRedrawBuffer
# TODO Set a height delta of 10px if anchor hex column is odd?

  constructor: () ->
    @redraw = document.createElement('canvas')

    @redraw.width = @width
    @redraw.height = @height

    @redraw_x = 0
    @redraw_y = 0
    @redraw_active = false

  reset_size: (x,y) ->
    # TODO this resets the w&h for this object but not for @redraw
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


  set_box_dimensions: () ->

    left = 30
    right = 0
    top = 100
    bottom = 0
    hx_top = 12
    hx_bottom = 0
    high_hex_col = null
    low_hex_col = null
    @high_hex_adjust = false

    @hexes = @piece.hexes
    for hx in @hexes
      aa = hx[0]
      bb = hx[1]
      b = 5 + 10*(bb-1) + 5*(aa%2)
      left = aa if aa < left
      right = aa if aa > right
      if b < top
        top = b
        hx_top = bb
        high_hex_col = aa
      if b > bottom
        bottom = b
        hx_bottom = bb
        low_hex_col = aa

    @anchor_hex = [left,hx_top]
    anchor_top = 5 + 10*(hx_top-1) + 5*(left%2)

    cols = right - left + 1
    halves = (bottom - top)/5 + 2
    @width = 6 + cols*14
    @height = halves*10

    a = @anchor_hex[0]
    b = @anchor_hex[1]
    if anchor_top > top
      high_hex_half_step = true
    else
      high_hex_half_step = false
    
    x = a*14+7
    y = b*20-12
    @box_xy = [x,y]

    ca_x = 10
    if high_hex_half_step then ca_y = 19 else ca_y = 9
    @center_to_anchor_delta = [ca_x,ca_y]


    if halves % 2 == 1
      if (high_hex_col - a) % 2 == 0 and a%2 == 1 then @high_hex_adjust = true

      anchor_in_hexes = false
      ax = @anchor_hex[0]
      ay = @anchor_hex[1]
      for hx in @hexes
        anchor_in_hexes = true if hx[0] == ax and hx[1] == ay

      if (not anchor_in_hexes) and (high_hex_col - a) % 2 == 1 and anchor_top < top
        console.log("Non-rendered anchor hex is out of bounds (higher than high hex).")
        @high_hex_adjust = true

    console.log("PieceRenderBox:")
    console.log("    top = "+top)
    console.log("    anchor_top = "+anchor_top)
    console.log("    high_hex_half_step = "+high_hex_half_step)
    console.log("    bottom = "+bottom)
    console.log("    left = "+left)
    console.log("    right = "+right)
    console.log("    center to anchor delta = "+@center_to_anchor_delta[0]+","+@center_to_anchor_delta[1])
#    console.log("     = "+)
#    console.log("     = "+)
    console.log("    cols = "+cols)
    console.log("    halves = "+halves)
    console.log("    WIDTH = "+@width)
    console.log("    HEIGHT = "+@height)
    console.log("    BOX-XY = "+@box_xy[0]+","+@box_xy[1])
    console.log("    HIGH HEX ADJUST = "+@high_hex_adjust)
    console.log("    ANCHOR HEX = "+@anchor_hex[0]+","+@anchor_hex[1])



class PuzzleView

  constructor: (puzzle_app) ->

    @puzzle = puzzle_app

    @puzzle_xy = [100,30]

    @backgrounds = ["#cc5050","#80cc50","#50b4cc",
                    "#b450cc","#cc8050","#50cc50",
                    "#5080cc","#cc50b4","#ccb450",
                    "#50cc80","#5050cc","#cc5080",
                    "#b4cc50","#50ccb4","#8050cc"]

    @canvas = document.getElementById("puzzle-widget")
    @context_canvas = @canvas.getContext('2d')

    @context = @get_drawing_context("canvas")
    @img = document.getElementById("photo")
    @context.drawImage(@img,@puzzle_xy[0],@puzzle_xy[1])


  get_drawing_context: (mode) ->
    switch mode
      when "canvas" then context = @context_canvas
      when "piece_mask"
        if @puzzle.piece
          context = @puzzle.piece.p_mask.img.getContext('2d')
        else
          context = null
    return context


class PuzzleGridModel

  constructor: () ->
      # When adjusting pixel-to-hex x,y alignments, make the changes on these
      # constants, not in the methods.
      @t_dx = 8
      @t_dy = -13


  get_xy: (a,b) -> 
    if @in_range(a,b)
      x = 100 + 14*a + (a%2)/2 + @t_dx
      y = 30 + 20*b + (a%2)*10 + @t_dy
      xy = [x,y]
    else
      xy = [0,0]
    return xy


  get_hex: (x,y) ->
    hex = [0,0]
    in_bounds = true
    aa = Math.floor((x-4-@t_dx)/14)-7
    bb = Math.floor((y-9*(aa%2)-10.5-@t_dy)/20)-1
    in_bounds = false if @in_range(aa,bb) == false

    corner = @get_xy(aa,bb)
    ctr_x = corner[0]+9
    ctr_y = corner[1]+10
    dx = Math.abs(x-ctr_x)
    dy = Math.abs(y-ctr_y)
    r2 = dx*dx+dy*dy
    in_bounds = false if r2>67 #(if radius > 8.2)

    hex = [aa,bb] if (in_bounds == true)
    return hex


  in_range: (a,b) ->
    a = 0 if not a?
    b = 0 if not b?
    ok = true
    ok = false if a<1 || a>24
    ok = false if b<1 || b>10
    ok = false if b == 10 && a%2 == 1
    return ok



class HexDraw

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @puzzle_view = @puzzle.puzzle_view

    @mode = null
    @context = null
    @colors = ["#cc5050","#5050cc","#50cccc","#50cc50","#cccc50","#cc50cc","#000000"]


  set_context: (mode) ->
    @mode = mode
    @context = @puzzle_view.get_drawing_context(mode)


  fill_hex_ab: (a,b,c_no) ->
    x = 113+a*14
    y = 27+b*20
    y = y-9 if (a%2 == 0)
    @fill_hex_xy(x,y,c_no)


  fill_hex_xy: (x,y,c_no) ->
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


  draw_all_hexes: () -> # [test/diagnostic method]
    @set_context("canvas")
    for row in [1..10]
      for col in [1..24]
        if row%2 == 0
          if col%2 == 0
            c = 1
          else
            c = 2
        else
          if col%2 == 0
            c = 3
          else
            c = 4
        @fill_hex_ab(col,row,c) unless (row==10 && col%2==1)



class HexBox

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @hexes = []
    @box_xy = [null,null]
    @corner_fit = "unknown"


  set_hex_box: (piece_symbol) ->
    @reset_hexes(@get_hexes(piece_symbol))
    @get_box_metrics()


  get_box_metrics: () ->

    @init_box_params()
    for hx in @hexes
      aa = hx[0]
      b2 = 2*hx[1] + aa%2 - 1
      @test_left_right_top_bottom(aa,b2)
    if @left%2 == 1
      @first_column = "odd"
    else
      @first_column = "even"

    console.log("HexBox: left = "+@left)
    console.log("HexBox: right = "+@right)
    console.log("HexBox: top = "+@top)
    console.log("HexBox: bottom = "+@bottom)
#    console.log("HexBox: ")
    console.log("HexBox: first column = "+@first_column)
#    console.log("HexBox: ")


  test_left_right_top_bottom: (aa,b2) ->
    @left = aa if aa < @left
    @right = aa if aa > @right
    @top = b2 if b2 < @top
    @bottom = b2 if b2 > @bottom

#      left = aa if aa < left
#      right = aa if aa > right
#      if b < top
#        top = b
#        hx_top = bb
#        high_hex_col = aa
#      if b > bottom
#        bottom = b
#        hx_bottom = bb
#        low_hex_col = aa


  init_box_params: () ->
    @left = 25
    @right = 0
    @top = 20
    @bottom = 0

#    hx_top = 12
#    hx_bottom = 0
#    high_hex_col = null
#    low_hex_col = null
#    @high_hex_adjust = false


  reset_hexes: (hex_collection) ->
    @hexes = hex_collection


  get_hexes: (piece_symbol) -> # TODO Leave this here or just reference the version in PuzzlePiece? 
    hexes = []
    for bb in [1..10]
      for aa in [1..24]
        hexes.push([aa,bb]) if @puzzle.pattern.grid[bb][aa] == piece_symbol
    console.log("PIECE ID: "+piece_symbol)
    console.log("    "+hx[0]+","+hx[1]) for hx in hexes
    return hexes



class HexGrid extends HexBox

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @corner_fit = "box-odd"
    @box_xy = @puzzle.puzzle_view.puzzle_xy



class HexDrawB

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @puzzle_view = @puzzle.puzzle_view

    @mode = null
    @context = null
    @colors = ["#cc5050","#5050cc","#50cccc","#50cc50","#cccc50","#cc50cc","#000000"]


  set_context: (mode) ->
    @mode = mode
    @context = @puzzle_view.get_drawing_context(mode)


  fill_hex_ab: (a,b,c_no) ->
    x = 113+a*14
    y = 27+b*20
    y = y-9 if (a%2 == 0)
    @fill_hex_xy(x,y,c_no)


  fill_hex_xy: (x,y,c_no) ->
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


  draw_all_hexes: () -> # [test/diagnostic method]
    @set_context("canvas")
    for row in [1..10]
      for col in [1..24]
        if row%2 == 0
          if col%2 == 0
            c = 1
          else
            c = 2
        else
          if col%2 == 0
            c = 3
          else
            c = 4
        @fill_hex_ab(col,row,c) unless (row==10 && col%2==1)



#   #   #   #   #   #
#   Global Scope Statements
#   #   #   #   #   #


@mousedown = (e) ->
  @app.events.click_handle(e)


start = () ->
  @app = new PuzzleApp()


window.onload = start


