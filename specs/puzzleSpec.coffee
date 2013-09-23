describe "Test of Photo Jigsaw Puzzle Widget", ->

  beforeEach ->
    @puzzle = new PuzzleApp()

  describe "App Creation Test", ->

    it "should create a PuzzleApp object", ->
      expect(@puzzle).toBeDefined
      expect(@puzzle).toEqual(jasmine.any(PuzzleApp))


  describe "View Creation Test", ->

    it "should create a view object", ->
      expect(@puzzle.puzzle_view).toBeDefined
      expect(@puzzle.puzzle_view).toEqual(jasmine.any(PuzzleView))

    it "should create an image object from the DOM", ->
      expect(@puzzle.puzzle_view.img).toBeDefined
      expect(@puzzle.puzzle_view.img).toEqual(jasmine.any(Image))


  describe "Puzzle Piece Tests", ->

    beforeEach ->
      @piece = @puzzle.piece

    it "should create a puzzle piece object", ->
      expect(@piece).toBeDefined
      expect(@piece).toEqual(jasmine.any(PuzzlePiece))

    it "should provide puzzle piece drawing size in pixels", ->
      expect(@piece.dim).toBeDefined
      expect(@piece.dim).toEqual(jasmine.any(Array))
      expect(@piece.dim).toEqual([63,87])

    it "should create a redraw buffer before drawing puzzle piece", ->
      expect(@piece.redraw).toBeDefined
      expect(@piece.redraw).toEqual(jasmine.any(HTMLCanvasElement))

    it "should set the dimensions of the redraw buffer to the puzzle piece drawing size", ->
      expect(@piece.redraw.width).toEqual(63)
      expect(@piece.redraw.height).toEqual(87)


  describe "Puzzle Grid Model Tests", ->

    beforeEach ->
      @grid = @puzzle.grid

    it "should create a puzzle grid model", ->
      expect(@grid).toBeDefined
      expect(@grid).toEqual(jasmine.any(PuzzleGridModel))

    it "should detect out of range hex coordinates", ->
      expect(@grid.in_range(0,0)).toEqual(false)
      expect(@grid.in_range(0,4)).toEqual(false)
      expect(@grid.in_range(1,1)).toEqual(true)
      expect(@grid.in_range(1,4)).toEqual(true)
      expect(@grid.in_range(1,9)).toEqual(true)
      expect(@grid.in_range(1,10)).toEqual(false)
      expect(@grid.in_range(2,10)).toEqual(true)
      expect(@grid.in_range(3,9)).toEqual(true)
      expect(@grid.in_range(3,10)).toEqual(false)
      expect(@grid.in_range(6,10)).toEqual(true)
      expect(@grid.in_range(8,7)).toEqual(true)
      expect(@grid.in_range(13,6)).toEqual(true)
      expect(@grid.in_range(15,0)).toEqual(false)
      expect(@grid.in_range(18,10)).toEqual(true)
      expect(@grid.in_range(19,10)).toEqual(false)
      expect(@grid.in_range(22,1)).toEqual(true)
      expect(@grid.in_range(23,9)).toEqual(true)
      expect(@grid.in_range(23,10)).toEqual(false)
      expect(@grid.in_range(24,2)).toEqual(true)
      expect(@grid.in_range(24,10)).toEqual(true)
      expect(@grid.in_range(25,5)).toEqual(false)
      expect(@grid.in_range(33,7)).toEqual(false)

    it "should convert hex coordinates to pixel coordinates", ->
      expect(@grid.get_xy(1,1)).toEqual([115,55])
      expect(@grid.get_xy(1,2)).toEqual([115,74])
      expect(@grid.get_xy(1,3)).toEqual([115,93])
      expect(@grid.get_xy(2,1)).toEqual([129,45])
      expect(@grid.get_xy(2,2)).toEqual([129,64])
      expect(@grid.get_xy(2,3)).toEqual([129,83])
      expect(@grid.get_xy(3,1)).toEqual([144,55])
      expect(@grid.get_xy(3,2)).toEqual([144,74])
      expect(@grid.get_xy(3,3)).toEqual([144,93])
      expect(@grid.get_xy(4,1)).toEqual([158,45])
      expect(@grid.get_xy(4,2)).toEqual([158,64])
      expect(@grid.get_xy(4,3)).toEqual([158,83])



