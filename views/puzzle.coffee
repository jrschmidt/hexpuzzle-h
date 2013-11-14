class PuzzleApp

  constructor: () ->
    @pz_status = new PuzzleStatus(this)
    @ui_status = new UiStatus(this)
    @events = new EventHandler(this)

    @puzzle_view = new PuzzleView(this)
    @grid_model = new PuzzleGridModel(this)
    @hex_draw = new HexDraw(this)
    @hex_box = new HexBox(this)
    @puzzle_pattern = new PuzzlePattern(this)
    @mask = new MissingPiecesMask(this)
    @piece = new PuzzlePiece(this)

    @pz_status.start_new_puzzle()



class EventHandler

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @ui_status = @puzzle.ui_status


  handle_mousedown: (e) ->
    @canvas = document.getElementById("puzzle-widget")
    dx = @canvas.offsetLeft
    dy = @canvas.offsetTop
    px = e.pageX
    py = e.pageY
    x = px-dx
    y = py-dy

    if @puzzle.piece.in_bounding_box(x,y)
      @ui_status.activate_piece_drag()
      @puzzle.hex_box.get_anchor_to_dragpoint(x,y)
      mouse_hex = @puzzle.grid_model.get_hex(x,y)


  handle_mouseup: (e) ->
    @ui_status.terminate_piece_drag() if @ui_status.drag_active


  handle_mousemove: (e) ->
    if @ui_status.drag_active

      @canvas = document.getElementById("puzzle-widget")
      dx = @canvas.offsetLeft
      dy = @canvas.offsetTop
      px = e.pageX
      py = e.pageY
      x = px-dx
      y = py-dy

      mouse_hex = @puzzle.grid_model.get_hex(x,y)
      mx_a = mouse_hex[0]
      mx_b = mouse_hex[1]
      if mx_a != 99
        if ( mx_a != @ui_status.active_hex[0] || mx_b != @ui_status.active_hex[1] )
          @ui_status.set_active_hex(mx_a,mx_b)
          @puzzle.piece.draw_piece_ab(mx_a,mx_b)
          @puzzle.pz_status.set_piece() if @puzzle.piece.piece_is_anchored(mx_a,mx_b)



class UiStatus

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app

    @drag_active = false
    @mouse_on_hex = false
    @active_hex = [99,99]


  set_active_hex: (a,b) ->
    @mouse_on_hex = true
    @active_hex = [a,b]


  disable_active_hex: () ->
    @mouse_on_hex = false
    @active_hex = [99,99]


  activate_piece_drag: () ->
    @drag_active = true


  terminate_piece_drag: () ->
    @drag_active = false



class PuzzleStatus

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @all_pieces = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]
    @pieces_in_puzzle = 16


  start_new_puzzle: () ->
    @unset_pieces = []
    @unset_pieces[p] = @puzzle.pz_status.all_pieces[p] for p in [0..15]
    @pieces_set = 0
    @puzzle.mask.start_color_cycle()
    @next_piece()


  set_piece: () ->
    @puzzle.ui_status.terminate_piece_drag()
    @pieces_set += 1
    @pieces_in_puzzle -= 1
    if @pieces_set == 16
      @puzzle_finished()
    else
      @next_piece()


  puzzle_finished: () ->
    @puzzle.puzzle_view.draw_photo()
    alert("Puzzle finished")


  next_piece: () ->
    @puzzle.mask.reset_mask()
    pc = Math.floor(@pieces_in_puzzle*Math.random())
    @sym = @unset_pieces[pc]
    @unset_pieces.splice(@unset_pieces.indexOf(@sym),1)
    @puzzle.piece.construct_piece(@sym)



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
    return grid



class MissingPiecesMask

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @puzzle_pattern = @puzzle.puzzle_pattern
    @grid = @puzzle_pattern.grid
    @hex_draw = @puzzle.hex_draw
    @backgrounds = ["#cc9999","#adcc99","#99c2cc",
                    "#c299cc","#ccad99","#99cc99",
                    "#99adcc","#cc99c2","#ccc299",
                    "#99ccad","#9999cc","#cc99ad",
                    "#c2cc99","#99ccc2","#ad99cc"]

    @init_missing_pieces_mask()


  init_missing_pieces_mask: () ->
    @missing = []
    @missing[p] = @puzzle.pz_status.all_pieces[p] for p in [0..15]
    @start_color_cycle()
    @puzzle.puzzle_view.draw_photo()


  reset_mask: () ->
    @puzzle.puzzle_view.draw_photo()
    @get_next_color()
    @draw_mask()


  start_color_cycle: () ->
    if Math.floor(2*Math.random()) > 1
      @color_direction = "up"
    else
      @color_direction = "down"
    @color_number = Math.floor(15*Math.random())
    @color = @backgrounds[@color_number]


  get_next_color: () ->
    switch @color_direction
      when "up"
        if @color_number == 14 then @color_number = 0 else @color_number += 1
      when "down"
        if @color_number == 0 then @color_number = 14 else @color_number -= 1
    @color = @backgrounds[@color_number]


  draw_mask: () ->
    @hex_draw.set_context("canvas")
    for bb in [1..10]
      for aa in [1..24]
        @hex_draw.fill_hex_ab(aa,bb,@color) if @grid[bb][aa] in @puzzle.pz_status.unset_pieces



class PuzzlePiece
  constructor: (puzzle_app) ->

    @puzzle = puzzle_app
    @hex_box = @puzzle.hex_box
    @piece_mask  = new PiecePattern(this)
    @redraw = new PieceRedrawBuffer(this)
    @hexes = []
    @bounding_box = [0,0,0,0,]


  construct_piece: (sym) ->
    @sym = sym
    @hexes = @get_hexes()
    @hex_box.set_hex_box(sym)
    wd_ht = @hex_box.get_box_size()
    @width = wd_ht[0]
    @height = wd_ht[1]
    @redraw.reset_size(@width,@height)
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
    @last_rendered_xy = xy


  draw_piece: (x,y) ->
    context = @puzzle.puzzle_view.context_canvas
    context.drawImage(@piece_mask.img,x,y)
    @reset_bounding_box(x,y)


  piece_is_anchored: (a,b) ->
    if @hex_box.anchor_hex[0] == a && @hex_box.anchor_hex[1] == b
      return true
    else
      return false


  reset_bounding_box: (x,y) ->
    @left = x
    @right = x + @width
    @top = y
    @bottom = y + @height


  in_bounding_box: (x,y) ->
    if x>@left && x<@right && y>@top && y<@bottom then return true else return false


  # TODO Does this method belong in PuzzlePattern class?
  get_hexes: () ->
    hexes = []
    for bb in [1..10]
      for aa in [1..24]
        hexes.push([aa,bb]) if @puzzle.puzzle_pattern.grid[bb][aa] == @sym
    return hexes



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
      @hex_draw.fill_hex_xy(xx,yy,"#000000")



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


    @canvas = document.getElementById("puzzle-widget")
    @context_canvas = @canvas.getContext('2d')


  draw_photo: () ->
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

    delta = @puzzle.hex_box.anchor_to_dragpoint
    xx = x - delta[0]
    yy = y - delta[1]

    aa = Math.floor((xx-12)/14)-7
    if aa%2 != 0 then odd = 1 else odd = 0
    bb = Math.floor((yy-9*odd+2.5)/20)-1
    corner = @puzzle.hex_box.get_box_xy_ab(aa,bb)
    ctr_x = corner[0]+9
    ctr_y = corner[1]+10
    dx = Math.abs(xx-ctr_x)
    dy = Math.abs(yy-ctr_y)
    r2 = dx*dx+dy*dy
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


  fill_hex_ab: (a,b,color) ->
    xy = @get_hex_xy(a,b)
    @fill_hex_xy(xy[0],xy[1],color)


  fill_hex_xy: (x,y,color) ->
    @context.fillStyle = color
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



class HexBox

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @hexes = []
    @box_xy = [null,null]
    @corner_fit = "unknown"


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
    @get_box_corner_to_anchor_hex_center()


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


  get_box_corner_to_anchor_hex_center: () ->
    if @corner_fit == "high"
      @box_corner_to_anchor_hex_center  = [9,10]
    else
      @box_corner_to_anchor_hex_center  = [9,20]


  get_anchor_to_dragpoint: (x,y) ->
    an_dp_x = x - @puzzle.piece.last_rendered_xy[0] - @box_corner_to_anchor_hex_center[0]
    an_dp_y = y - @puzzle.piece.last_rendered_xy[1] - @box_corner_to_anchor_hex_center[1]
    @anchor_to_dragpoint = [an_dp_x,an_dp_y]


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



#   #   #   #   #   #
#   Global Scope Statements
#   #   #   #   #   #


@mousedown = (e) ->
  @app.events.handle_mousedown(e)


@mouseup = (e) ->
  @app.events.handle_mouseup(e)


@mousemove = (e) ->
  @app.events.handle_mousemove(e)


start = () ->
  @app = new PuzzleApp()


window.onload = start


