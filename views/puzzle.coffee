class PuzzleApp

  constructor: () ->
    @pz_status = new PuzzleStatus(this)
    @ui_status = new UiStatus(this)
    @events = new EventHandler(this)

    @puzzle_view = new PuzzleView(this)
    @hex_box = new HexBox(this)
    @hex_draw = new HexDraw(this)
    @piece = new PuzzlePiece(this)
    @colors = new ColorRotation
    @indicator = new Indicator(this)
    @grid_model = new PuzzleGridModel(this)
    @mask = new MissingPiecesMask(this)
    get_puzzle_pattern(this)



class EventHandler

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @pz_status = @puzzle.pz_status
    @ui_status = @puzzle.ui_status


  handle_mousedown: (e) ->
    @canvas = document.getElementById("puzzle-widget")
    dx = @canvas.offsetLeft
    dy = @canvas.offsetTop
    px = e.pageX
    py = e.pageY
    x = px-dx
    y = py-dy

    if @pz_status.finished == true
      @pz_status.start_new_puzzle()
    else
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


  reset: () ->
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


  start_new_puzzle: () ->
    @finished = false
    @unset_pieces = @all_pieces.slice(0, 16)
    console.log "start_new_puzzle()"
    up = ""
    @unset_pieces.forEach (pcc) ->
      up = up + pcc
    console.log "   @unset_pieces = #{up}"
    @pieces_in_puzzle = 16
    @pieces_set = 0
    @puzzle.mask.reset_mask(@puzzle.grid)
    @puzzle.ui_status.reset()
    @puzzle.puzzle_view.reset()
    @start_first_piece()


  set_piece: () ->
    console.log " "
    console.log "set_piece()"
    @puzzle.ui_status.terminate_piece_drag()
    @pieces_set += 1
    @pieces_in_puzzle -= 1
    console.log "   pieces_set = #{@pieces_set}"
    console.log "   pieces_in_puzzle = #{@pieces_in_puzzle}"
    if @pieces_set == 16
      @puzzle_finished()
    else
      @next_piece()


  puzzle_finished: () ->
    @puzzle.puzzle_view.draw_photo()
    @finished = true



  next_piece: () ->
    @puzzle.mask.reset_mask(@puzzle.grid)
    @puzzle.indicator.decrement()
    pc = Math.floor(@pieces_in_puzzle*Math.random())
    @sym = @unset_pieces[pc]
    @unset_pieces.splice(@unset_pieces.indexOf(@sym),1)
    console.log " "
    console.log "next_piece()"
    console.log "   sym = #{@sym}"
    console.log "   pc = #{pc}"
    up = ""
    @unset_pieces.forEach (pcc) ->
      up = up + pcc
    console.log "   @unset_pieces = #{up}"
    @puzzle.piece.construct_piece(@sym)


  start_first_piece: () ->
    @puzzle.colors.new_rotation()
    @puzzle.indicator.start_indicator()
    pc = Math.floor(@pieces_in_puzzle*Math.random())
    @sym = @unset_pieces[pc]
    @unset_pieces.splice(@unset_pieces.indexOf(@sym),1)
    up = ""
    @unset_pieces.forEach (pcc) ->
      up = up + pcc
    console.log " "
    console.log "start_first_piece()"
    console.log "   @unset_pieces = #{up}"
    console.log "   sym = #{@sym}"
    console.log "   pc = #{pc}"
    @puzzle.piece.construct_piece(@sym)



class MissingPiecesMask

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @puzzle_pattern = @puzzle.puzzle_pattern
    @hex_draw = @puzzle.hex_draw


  reset_mask: (grid) ->
    @puzzle.puzzle_view.draw_photo()
    @grid = grid
    @get_next_color()
    @draw_mask(grid)


  get_next_color: () ->
    @color = @puzzle.colors.next_color()


  draw_mask: (grid) ->
    @hex_draw.set_context("canvas")
    for bb in [1..10]
      for aa in [1..24]
        @hex_draw.fill_hex_ab(aa,bb,@color) if grid[bb][aa] in @puzzle.pz_status.unset_pieces



class PuzzlePiece

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @hex_box = @puzzle.hex_box
    @pattern  = new PiecePattern(this)
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
    @pattern.draw_piece_pattern()
    @cut_piece_from_photo()
    @draw_piece_ab(-7,5)


  get_hexes: () ->
    hexes = []
    for bb in [1..10]
      for aa in [1..24]
        hexes.push([aa,bb]) if @puzzle.grid[bb][aa] == @sym
    return hexes


  cut_piece_from_photo: () ->

    @photo_clip = document.createElement('canvas')
    @photo_clip.id = "photo-clip"
    @photo_clip.width = @hex_box.width
    @photo_clip.height = @hex_box.height
    @photo_clip_context = @photo_clip.getContext('2d')
    xx = @hex_box.box_xy[0] - @puzzle.puzzle_view.puzzle_xy[0]
    yy = @hex_box.box_xy[1] - @puzzle.puzzle_view.puzzle_xy[1]
    photo = @puzzle.puzzle_view.photo
    console.log "xx is negative" if xx < 0
    console.log "yy is negative" if yy < 0
    console.log "@hex_box.width is negative" if @hex_box.width < 0
    console.log "@hex_box.height is negative" if @hex_box.height < 0
    @photo_clip_context.drawImage(photo,xx,yy,@hex_box.width,@hex_box.height,0,0,@hex_box.width,@hex_box.height)
    @puzzle.mask.reset_mask(@puzzle.grid)
    context = @pattern.img.getContext('2d')
    context.globalCompositeOperation = 'source-atop'
    context.drawImage(@photo_clip,0,0)
    context.globalCompositeOperation = 'source-over'


  draw_piece_ab: (a,b) ->
    xy = @puzzle.hex_box.get_box_xy_ab(a,b)
    @draw_piece(xy[0],xy[1])
    @last_rendered_xy = xy


  draw_piece: (x,y) ->
    @redraw.apply_redraw()
    @redraw.prepare_next_redraw(x,y)
    context = @puzzle.puzzle_view.context_canvas
    context.drawImage(@pattern.img,x,y)
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
    context = @img.getContext('2d')
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
      @hex_draw.set_context2(@img)
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

  reset_size: (x,y) ->
    @width = x
    @height = y
    @redraw_image.width = @width
    @redraw_image.height = @height


  apply_redraw: () ->
    canvas = document.getElementById("puzzle-widget")
    context = canvas.getContext('2d')
    context.drawImage(@redraw_image,@redraw_x,@redraw_y)


  prepare_next_redraw: (x,y) ->
    ctx = @redraw_image.getContext('2d')
    ctx.clearRect(0,0,@width,@height)
    ht = @height
    if y < 0
      ht = ht + y
      y = 0
    wd = @width
    if x < 0
      wd = wd + x
      x = 0
    ctx.drawImage(@view.canvas,x,y,wd,ht,0,0,wd,ht)
    @redraw_x = x
    @redraw_y =y



class PuzzleView

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @puzzle_xy = [100,30]
    @reset()
    @photo = new Image()
    @photo.onload = =>
      @draw_photo()
    @photo.src = '/pz-photo'


  reset: () ->
    @canvas = document.getElementById("puzzle-widget")
    @context_canvas = @canvas.getContext('2d')
    @context_canvas.fillStyle = "#999999"
    @context_canvas.fillRect(0,0,520,280)


  draw_photo: () ->
    @context = @get_drawing_context("canvas")
    @context.drawImage(@photo,@puzzle_xy[0],@puzzle_xy[1])


  get_drawing_context: (mode) ->
    switch mode
      when "canvas" then context = @context_canvas
      when "piece-mask"
        pm_img = document.getElementById("piece-mask")
        context = pm_img.getContext('2d')
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


  set_context2: (img) ->
    @context = img.getContext('2d')


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
    console.log " "
    console.log "set_hex_box()"
    console.log "   symbol = #{piece_symbol}"
    @reset_hexes(@get_hexes(piece_symbol))
    console.log "   after reset_hexes():"
    console.log "      hexes.length = #{@hexes.length}"
    @get_box_metrics()


  reset_hexes: (hex_collection) ->
    @hexes = hex_collection


  get_box_metrics: () ->
    console.log "   get_box_metrics()"
    @init_box_params()
    for hx in @hexes
      aa = hx[0]
      b2 = 2*hx[1] + aa%2 - 1
      @test_left_right_top_bottom(aa,b2)
    @get_corner_fit()
    @get_anchor_hex()
    console.log "      anchor_hex is [#{@anchor_hex[0]},#{@anchor_hex[1]}]"
    @get_box_xy()
    @get_height_width()
    console.log "         @get_height_width()"
    console.log "             right = #{@right}"
    console.log "              left = #{@left}"
    console.log "            bottom = #{@bottom}"
    console.log "               top = #{@top}"
    console.log "             width = #{@width}"
    console.log "            height = #{@height}"
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
        hexes.push([aa,bb]) if @puzzle.grid[bb][aa] == piece_symbol
    return hexes



class Indicator

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app


  start_indicator: () ->
    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext('2d')
    @context.fillStyle = 'black'
    for p in [16..1]
      @context.fillStyle = @puzzle.colors.rotation[16-p]
      xp = 489-17*p
      yp = 6
      @context.beginPath()
      @context.moveTo(xp+5,yp)
      @context.lineTo(xp+12,yp)
      @context.lineTo(xp+12,yp+17)
      @context.lineTo(xp+5,yp+17)
      @context.lineTo(xp,yp+8)
      @context.lineTo(xp+5,yp)
      @context.fill()
      @context.closePath()
    @write_message(16)


  decrement: () ->
    @write_message(@puzzle.pz_status.pieces_in_puzzle)


  write_message: (n) ->
    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext('2d')
    @context.fillStyle = "#999999"
    @context.fillRect(100,0,115+17*(16-n),30)
    @context.fillStyle = "#333333"
    @context.font = "bold 14px sans-serif"
    @context.textAlign = "left"
    @context.textbaseline = "top"
    if n == 1
      msg = "1 piece left"
      cx = 374
    else
      msg = n.toString() + " pieces left"
      cx = 100+17*(16-n)
      cx = cx + 10 if n < 10
    @context.fillText(msg,cx,20)



class ColorRotation

  constructor: (puzzle_app) ->
    @puzzle = puzzle_app
    @app_colors = ["#cc9999","#a0cc99","#99a6cc","#cc99ad",
                   "#b3cc99","#99b9cc","#cc99bf","#c6cc99",
                   "#99cccc","#c599cc","#ccbf99","#99ccb8",
                   "#b399cc","#ccac99","#99cca6","#9f99cc"]


  new_rotation: () ->
    if Math.floor(2*Math.random()) > 1
      @color_direction = "up"
    else
      @color_direction = "down"
    @start_number = Math.floor(16*Math.random())
    @rotation = @build_rotation()


  build_rotation: () ->
    rr = []
    rr.push(@app_colors[i]) for i in [@start_number..15]
    rr.push(@app_colors[i]) for i in [0..@start_number-1] if @start_number > 0
    rr = rr.reverse() if @color_direction == "down"
    return rr


  next_color: () ->
    @rotation = @build_rotation if @rotation == undefined
    if @rotation.length > 0
      return @rotation.shift()
    else
      return "#333333"



#   #   #   #   #   #
#   Global Scope Statements
#   #   #   #   #   #


@mousedown = (e) ->
  @app.events.handle_mousedown(e)


@mouseup = (e) ->
  @app.events.handle_mouseup(e)


@mousemove = (e) ->
  @app.events.handle_mousemove(e)


get_puzzle_pattern = (app) ->
  xhr = new XMLHttpRequest()
  url = "/puzzle-pattern"
  xhr.open('GET',url)
  xhr.onreadystatechange = ->
    if (xhr.readyState == 4 && xhr.status == 200)
      msg_in = xhr.responseText
      response = JSON.parse(msg_in)
      @pstring = response.pstring
      app.grid = get_pattern_grid(@pstring)
      app.pz_status.start_new_puzzle()
  xhr.send()


get_pattern_grid = (data_string) ->
  grid = []
  n = 0
  for row in [1..10]
    grid[row] = []
    for col in [1..24]
      ch = data_string[n]
      grid[row][col] = ch
      n = n+1
  return grid



start = () ->
  @app = new PuzzleApp()


window.onload = start
