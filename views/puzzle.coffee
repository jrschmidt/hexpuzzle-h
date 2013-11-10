class PuzzleApp

  constructor: () ->
    @puzzle_view = new PuzzleView(this)
    @grid_model = new PuzzleGridModel(this)
    @hex_grid = new HexGrid(this)
    @hex_draw = new HexDraw(this)

    @hex_box = new HexBox(this)

    @events = new EventHandler(this)

    @puzzle_pattern = new PuzzlePattern(this)
    @mask = new MissingPiecesMask(this)
    @piece = new PuzzlePiece(this)


#    @puzzle_pattern.draw_pattern()
#    @hex_draw.draw_all_hexes()
    @hex_draw.fill_all_hexes()

    pieces = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]
    pc = Math.floor(16*Math.random())
    @piece.construct_piece(pieces[pc])

    @pixel_test = new PixelHexTester(this)
    @pixel_test.adjusted_hex_quick_mark()



class EventHandler

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @grid_model = @puzzle.grid_model

    @piece_drag = new PieceDrag(@puzzle)

    @show_clicks = true


  click_handle: (e) ->
    @canvas = document.getElementById("puzzle-widget")
    dx = @canvas.offsetLeft
    dy = @canvas.offsetTop
    px = e.pageX
    py = e.pageY
    x = px-dx
    y = py-dy

    console.log("mouse click: "+x+","+y)
    @puzzle.pixel_test.big_dot(x,y) if @show_clicks == true
    hex = @piece_drag.get_piece_hex_position(x,y)
    console.log("A*,B* ~= "+hex[0]+","+hex[1])
    @puzzle.piece.draw_piece_ab(hex[0],hex[1])



class PieceDrag

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @hex_box = @puzzle.hex_box
    @grid_model = @puzzle.grid_model


  get_piece_hex_position: (x,y) ->
    dxdy = @get_piece_offset()
    hex = @grid_model.get_hex(x-dxdy[0],y-dxdy[1])
    return hex


  get_piece_offset: () ->
    wd_ht = @hex_box.get_box_size()
    dx = Math.floor(wd_ht[0]/2) - 10
    dy = Math.floor(wd_ht[1]/2) - 10
    console.log("piece center to anchor hex offset = "+dx+","+dy)
    return [dx,dy]



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
    @puzzle_pattern = @puzzle.puzzle_pattern
    @grid = @puzzle_pattern.grid
    @hex_draw = @puzzle.hex_draw
    @missing = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]


  draw_mask: () ->
    @hex_draw.set_context("canvas")
    for bb in [1..10]
      for aa in [1..24]
        @hex_draw.fill_hex_ab(aa,bb,0) if @grid[bb][aa] in @missing



class PuzzlePiece
  constructor: (puzzle_app) ->

    @puzzle = puzzle_app
    @hex_box = @puzzle.hex_box
    @piece_mask  = new PiecePattern(this)
    @redraw = new PieceRedrawBuffer(this)
    @hexes = []


  construct_piece: (sym) ->
    @sym = sym
    @hexes = @get_hexes()
    @hex_box.set_hex_box(sym)
    wd_ht = @hex_box.get_box_size()
    @redraw.reset_size(wd_ht[0],wd_ht[1])

    @piece_mask.draw_piece_pattern()
    @cut_piece_from_photo()
    @draw_piece_ab(-7,5)


  cut_piece_from_photo: () ->

    @photo_clip = document.createElement('canvas')
    @photo_clip.id = "photo-clip"
    @photo_clip.width = @hex_box.width
    @photo_clip.height = @hex_box.height
    @photo_clip_context = @photo_clip.getContext('2d')

    xx = @hex_box.box_xy[0] - @puzzle.puzzle_view.puzzle_xy[0]
    yy = @hex_box.box_xy[1] - @puzzle.puzzle_view.puzzle_xy[1]

    photo = document.getElementById(@puzzle.puzzle_view.photo)
    @photo_clip_context.drawImage(photo,xx,yy,@hex_box.width,@hex_box.height,0,0,@hex_box.width,@hex_box.height)

    context = @piece_mask.piece_mask_context
    context.globalCompositeOperation = 'source-atop'
    context.drawImage(@photo_clip,0,0)
    context.globalCompositeOperation = 'source-over'


  draw_piece_ab: (a,b) ->
    xy = @puzzle.hex_box.get_box_xy_ab(a,b)
    @redraw.apply_redraw()
    @redraw.prepare_next_redraw(xy[0],xy[1])
    @draw_piece(xy[0],xy[1])


  draw_piece: (x,y) ->
    context = @puzzle.puzzle_view.context_canvas
    context.drawImage(@piece_mask.img,x,y)


  # TODO Does this method belong in PuzzlePattern class?
  get_hexes: () ->
    hexes = []
    for bb in [1..10]
      for aa in [1..24]
        hexes.push([aa,bb]) if @puzzle.puzzle_pattern.grid[bb][aa] == @sym
    console.log("PIECE ID: "+@sym)
    console.log("    "+hx[0]+","+hx[1]) for hx in hexes
    hexes



class PiecePattern

  constructor: (piece) ->
    @piece = piece
    @puzzle = @piece.puzzle
    @hex_box = @puzzle.hex_box
    @hex_draw = @puzzle.hex_draw
    @img = document.createElement('canvas')
    @img.id = "piece-mask"
    @piece_mask_context = @img.getContext('2d')


  draw_piece_pattern: () ->
    @img.width = @hex_box.width
    @img.height = @hex_box.height
    @hexes = @piece.hexes
    @hex_draw.set_context("piece_mask")
    anchor_a = @hex_box.anchor_hex[0]
    anchor_b = @hex_box.anchor_hex[1]
    anchor_x = 0
    if @hex_box.corner_fit == "high" then anchor_y = 0 else anchor_y = 10

    for hx in @hexes
      aa = hx[0]
      bb = hx[1]
      xx = (aa - anchor_a) * 14
      yy = anchor_y + (bb - anchor_b) * 20
      if aa%2 != anchor_a%2
        if anchor_a%2 == 0 then yy = yy+10 else yy = yy-10
      @hex_draw.fill_hex_xy(xx,yy,3)



class PieceRedrawBuffer

  constructor: (piece) ->
    @piece = piece
    @puzzle = @piece.puzzle
    @view = @puzzle.puzzle_view

    @redraw_image = document.createElement('canvas')
    @redraw_image.width = 30
    @redraw_image.height = 30
    @redraw_x = 0
    @redraw_y = 0
    @redraw_active = false

  reset_size: (x,y) ->
    @width = x
    @height = y
    @redraw_image.width = @width
    @redraw_image.height = @height


  apply_redraw: () ->
    if @redraw_active
      canvas = document.getElementById("puzzle-widget")
      context = canvas.getContext('2d')
      context.drawImage(@redraw_image,@redraw_x,@redraw_y)
      @view.clear_margins()


  prepare_next_redraw: (x,y) ->
    ctx = @redraw_image.getContext('2d')
    ctx.clearRect(0,0,@width,@height)
    ctx.drawImage(@view.canvas,x,y,@width,@height,0,0,@width,@height)
    @redraw_active = true
    @redraw_x = x
    @redraw_y =y



class PuzzleView

  constructor: (puzzle_app) ->

    @puzzle = puzzle_app

    @photo_picker = new PhotoPicker
    @photo = @photo_picker.pick_new_photo()

    @puzzle_xy = [100,30]

    @top_margin = [100,0,384,30]
    @right_margin = [484,0,36,246]
    @bottom_margin = [100,246,420,34]
    @left_margin = [0,0,100,280]

    @backgrounds = ["#cc9999","#adcc99","#99c2cc",
                    "#c299cc","#ccad99","#99cc99",
                    "#99adcc","#cc99c2","#ccc299",
                    "#99ccad","#9999cc","#cc99ad",
                    "#c2cc99","#99ccc2","#ad99cc"]

    @canvas = document.getElementById("puzzle-widget")
    @context_canvas = @canvas.getContext('2d')

    @context = @get_drawing_context("canvas")

    @img = document.getElementById(@photo)
    @context.drawImage(@img,@puzzle_xy[0],@puzzle_xy[1])


  clear_margins: () ->
    tp = @top_margin
    rt = @right_margin
    bt = @bottom_margin
    lf = @left_margin
    @context = @get_drawing_context("canvas")
    @context.clearRect(tp[0],tp[1],tp[2],tp[3])
    @context.clearRect(rt[0],rt[1],rt[2],rt[3])
    @context.clearRect(bt[0],bt[1],bt[2],bt[3])
    @context.clearRect(lf[0],lf[1],lf[2],lf[3])


  get_drawing_context: (mode) ->
    switch mode
      when "canvas" then context = @context_canvas
      when "piece_mask"
        if @puzzle.piece
          context = @puzzle.piece.piece_mask.img.getContext('2d')
        else
          context = null
    return context


class PuzzleGridModel

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app


  get_hex: (x,y) ->
    hex = [99,99]
    in_bounds = true
    aa = Math.floor((x-12)/14)-7
    if aa%2 != 0 then odd = 1 else odd = 0
    bb = Math.floor((y-9*odd+2.5)/20)-1
    console.log("ab = "+[aa,bb])
    corner = @puzzle.hex_box.get_box_xy_ab(aa,bb)
    console.log("corner = "+corner)
    ctr_x = corner[0]+9
    ctr_y = corner[1]+10
    console.log("center = "+ctr_x+","+ctr_y)
    dx = Math.abs(x-ctr_x)
    dy = Math.abs(y-ctr_y)
    console.log("dx = "+dx)
    console.log("dy = "+dy)
    r2 = dx*dx+dy*dy
    console.log("r2 = "+r2)
    in_bounds = false if r2>67 #(if radius > 8.2)

    hex = [aa,bb] if (in_bounds == true)
    return hex



class HexDraw

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @puzzle_view = @puzzle.puzzle_view
    @hex_box = @puzzle.hex_box

    @mode = null
    @context = null

    @dx = 108
    @dy = 18
    @colors = ["#cc5050","#5050cc","#50cccc","#50cc50","#cccc50","#cc50cc","#000000"]


  set_context: (mode) ->
    @mode = mode
    @context = @puzzle_view.get_drawing_context(mode)


  get_hex_xy: (a,b) ->
    x = a*14 + @dx
    if a%2 != 0 then odd = 1 else odd = 0
    y = (2*b + odd)*10 + @dy
    xy = [x,y]
    return xy


  fill_hex_ab: (a,b,c_no) ->
    alert("fill_hex_ab: "+a+","+b+"  "+c_no) if c_no == 1
    xy = @get_hex_xy(a,b)
    @fill_hex_xy(xy[0],xy[1],c_no)


  fill_hex_xy: (x,y,c_no) ->
    @context.fillStyle = @colors[c_no]
    @context.beginPath()
    @context.moveTo(x+5,y)
    @context.lineTo(x+15,y)
    @context.lineTo(x+20,y+11)
    @context.lineTo(x+15,y+20)
    @context.lineTo(x+4,y+20)
    @context.lineTo(x-1,y+10)
    @context.lineTo(x+5,y)
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


  fill_all_hexes: () -> # [test/diagnostic method]
    @set_context("canvas")
    for row in [1..10]
      for col in [1..24]
        @fill_hex_ab(col,row,4) unless (row==10 && col%2==1)



class HexBox

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @hexes = []
    @box_xy = [null,null]
    @corner_fit = "unknown"
    @metrics_report = true


  set_hex_box: (piece_symbol) ->
    @reset_hexes(@get_hexes(piece_symbol))
    @get_box_metrics()


  reset_hexes: (hex_collection) ->
    @hexes = hex_collection


  get_box_metrics: () ->
    @init_box_params()
    for hx in @hexes
      aa = hx[0]
      b2 = 2*hx[1] + aa%2 - 1
      @test_left_right_top_bottom(aa,b2)
    @get_corner_fit()
    @get_anchor_hex()
    @get_box_xy()
    @get_height_width()
    @report_metrics() if @metrics_report == true


  get_height_width: () ->
    @width = 14*(@right-@left+1) + 7
    @height = 10*(@bottom-@top+2) + 1


  get_box_size: () ->
    return [@width,@height]


  get_anchor_hex: () ->
    aa = @left
    bb = (@top + @top%2)/2
    bb = bb + 1 if @left%2 == 0 && @corner_fit == "low"
    @anchor_hex = [aa,bb]


  get_box_xy: () ->
    @box_xy = @get_box_xy_ab(@anchor_hex[0],@anchor_hex[1])


  get_box_xy_ab: (a,b) ->
    xy = @puzzle.hex_draw.get_hex_xy(a,b)
    xy[1] = xy[1] - 10 if @corner_fit == "low"
    return xy


  get_corner_fit: () ->
    if @left%2 == 1
      if @top%2 == 1
        @corner_fit = "low"
      else
        @corner_fit = "high"
    else
      if @top%2 == 1
        @corner_fit = "high"
      else
        @corner_fit = "low"


  test_left_right_top_bottom: (aa,b2) ->
    @left = aa if aa < @left
    @right = aa if aa > @right
    @top = b2 if b2 < @top
    @bottom = b2 if b2 > @bottom


  init_box_params: () ->
    @left = 25
    @right = 0
    @top = 20
    @bottom = 0


  get_hexes: (piece_symbol) ->
    hexes = []
    for bb in [1..10]
      for aa in [1..24]
        hexes.push([aa,bb]) if @puzzle.puzzle_pattern.grid[bb][aa] == piece_symbol
    return hexes


  report_metrics: () ->
    console.log("HexBox: left = "+@left)
    console.log("HexBox: right = "+@right)
    console.log("HexBox: top = "+@top)
    console.log("HexBox: bottom = "+@bottom)
    console.log("HexBox: width = "+@width)
    console.log("HexBox: height = "+@height)
    console.log("HexBox: corner fit = "+@corner_fit)
    console.log("HexBox: anchor hex ="+@anchor_hex)
    console.log("HexBox: box XY ="+@box_xy[0]+","+@box_xy[1])



class HexGrid extends HexBox

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @corner_fit = "box-odd"
    @box_xy = @puzzle.puzzle_view.puzzle_xy



class PhotoPicker

  constructor: () ->
    @photo_list = ["hx005","hx033","hx143","hx156","hx165",
                   "hx223","hx237","hx298","hx384","hx418",
                   "hx476","hx531","hx547","hx636","hx661",
                   "hx729","hx781","hx790","hx792","hx800",
                   "hx808","hx813","hx820","hx831","hx836",
                   "hx849","hx860","hx876"]


  pick_new_photo: () ->
    photo_number = Math.floor((@photo_list.length)*Math.random())
    return @photo_list[photo_number]



class PixelHexTester


  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @xx = 120
    @yy = 30
    @wd = 350
    @ht = 220


  test: (n) ->
    for k in [0..n]
      for z in [1.1000]
        @pixel_test()
        alert("pixel test: "+k)


  pixel_test: () ->
    x = @xx + Math.floor(@wd*Math.random())
    y = @yy + Math.floor(@ht*Math.random())
    @dot(x,y)


  hex_quick_mark: () ->
    for aa in [1..24]
      for bb in [1..10]
        if not (aa%2 == 1 and bb == 10)
          corner = @puzzle.hex_box.get_box_xy_ab(aa,bb)
          ctr_x = corner[0]+9
          ctr_y = corner[1]+10
          @circle_hex(ctr_x,ctr_y)


  adjusted_hex_quick_mark: () ->
    dxy = @puzzle.events.piece_drag.get_piece_offset()
    for aa in [-7..24]
      for bb in [1..10]
        if aa == 1 && bb == 1 then origin = true else origin = false
        if not (aa%2 == 1 and bb == 10)
          corner = @puzzle.hex_box.get_box_xy_ab(aa,bb)
          ctr_x = corner[0]+9+dxy[0]
          ctr_y = corner[1]+10+dxy[1]
          hx11 = [corner[0]-9,corner[1]-10] if aa == 1 && bb == 1
          @circle_hex(ctr_x,ctr_y,origin)


  circle_hex: (x,y,origin) ->
    canvas = document.getElementById("puzzle-widget")
    context = canvas.getContext('2d')
    context.strokeStyle = "black"
    context.fillStyle = "blue"
    context.beginPath()
    context.arc(x,y,8.2,0,6.28)
    context.stroke()
    context.fill() if origin == true
    context.closePath()


  mark_hex_centerpoints: () ->
    for aa in [1..24]
      for bb in [1..10]
        if not (aa%2 == 1 and bb == 10)
          corner = @puzzle.hex_box.get_box_xy_ab(aa,bb)
          @put_dot(corner[0],corner[1],"#666666")
          ctr_x = corner[0]+9
          ctr_y = corner[1]+10
          @put_dot(ctr_x,ctr_y,"#ff0000")


  dot: (x,y) ->
    hex = @puzzle.events.piece_drag.get_piece_hex_position(x,y)
    if hex[0] > 0 and hex[0] < 25 and hex[1] > 0 and hex[1] < 11
      color = @get_dot_color(hex)
      @put_dot(x,y,color)


  put_dot: (x,y,color) ->
    canvas = document.getElementById("puzzle-widget")
    context = canvas.getContext('2d')
    context.fillStyle = color
    context.fillRect(x,y,1,1)


  big_dot: (x,y) ->
    canvas = document.getElementById("puzzle-widget")
    context = canvas.getContext('2d')
    context.fillStyle = "black"
    context.fillRect(x-1,y-1,3,3)


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



#   #   #   #   #   #
#   Global Scope Statements
#   #   #   #   #   #


@mousedown = (e) ->
  @app.events.click_handle(e)


start = () ->
  @app = new PuzzleApp()


window.onload = start


