// Generated by CoffeeScript 1.6.3
var PuzzleApp, PuzzlePiece, PuzzleView, start;

PuzzleApp = (function() {
  function PuzzleApp() {
    this.puzzle_view = new PuzzleView;
    this.piece = new PuzzlePiece;
    this.piece.draw_piece();
  }

  return PuzzleApp;

})();

PuzzlePiece = (function() {
  function PuzzlePiece() {}

  PuzzlePiece.prototype.draw_piece = function() {
    this.canvas = document.getElementById("puzzle-widget");
    this.context = this.canvas.getContext("2d");
    this.pc_img = document.getElementById("piece");
    return this.context.drawImage(this.pc_img, 0, 100);
  };

  return PuzzlePiece;

})();

PuzzleView = (function() {
  function PuzzleView() {
    this.canvas = document.getElementById("puzzle-widget");
    this.context = this.canvas.getContext("2d");
    this.img = document.getElementById("frame");
    this.context.drawImage(this.img, 100, 30);
  }

  return PuzzleView;

})();

start = function() {
  return this.app = new PuzzleApp();
};

window.onload = start;
