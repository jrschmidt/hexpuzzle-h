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

    it "should create a puzzle piece object", ->
      expect(@puzzle.piece).toBeDefined
      expect(@puzzle.piece).toEqual(jasmine.any(PuzzlePiece))


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



