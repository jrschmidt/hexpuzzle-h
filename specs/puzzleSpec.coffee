describe "Test of Photo Jigsaw Puzzle Widget", ->

  beforeEach ->
    @puzzle = new PuzzleApp()

  describe "App Creation Test", ->

    it "should create a PuzzleApp object", ->
      expect(@puzzle).toBeDefined
      expect(@puzzle).toEqual(jasmine.any(PuzzleApp))


  describe "View Creation Test", ->

    it "should create a View object", ->
      expect(@puzzle.puzzle_view).toBeDefined
      expect(@puzzle.puzzle_view).toEqual(jasmine.any(PuzzleView))

    it "should create an image object from the DOM", ->
      expect(@puzzle.puzzle_view.img).toBeDefined
      expect(@puzzle.puzzle_view.img).toEqual(jasmine.any(Image))

  describe "Puzzle piece Tests", ->
    it "should create a puzzle piece object", ->
      expect(@puzzle.piece).toBeDefined
      expect(@puzzle.piece).toEqual(jasmine.any(PuzzlePiece))


