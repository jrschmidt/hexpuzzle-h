describe "Test of Photo Jigsaw Puzzle Widget", ->

  beforeEach ->
    @puzzle = new PuzzleApp()

  describe "App Creation Test", ->

    it "should create a PuzzleApp object", ->
      expect(@puzzle).toBeDefined
      expect(@puzzle).toEqual(jasmine.any(PuzzleApp))



