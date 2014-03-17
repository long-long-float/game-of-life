// Generated by CoffeeScript 1.6.2
(function() {
  (function($) {
    var Game, game;

    Game = (function() {
      function Game(opt, $canvas) {
        this.opt = $.extend({
          width: 100,
          height: 100,
          fps: 30,
          oninit: function(canvas) {},
          onframe: function(canvas) {}
        }, opt);
        this.canvas = $canvas.attr('width', this.opt.width).attr('height', this.opt.height).get(0).getContext('2d');
        this.opt.oninit();
      }

      Game.prototype.start = function() {
        var _this = this;

        if (this.intervalID) {
          return;
        }
        return this.intervalID = setInterval((function() {
          var old;

          old = _this.canvas.fillStyle;
          _this.canvas.fillStyle = '#fff';
          _this.canvas.fillRect(0, 0, _this.opt.width, _this.opt.height);
          _this.canvas.fillStyle = old;
          return _this.opt.onframe(_this.canvas);
        }), 1000.0 / this.opt.fps);
      };

      Game.prototype.stop = function() {
        if (!this.intervalID) {
          return;
        }
        clearInterval(this.intervalID);
        return this.intervalID = null;
      };

      return Game;

    })();
    game = null;
    return $.fn.game = function(opt) {
      switch (opt) {
        case 'start':
          game.start();
          break;
        case 'stop':
          game.stop();
          break;
        default:
          game = new Game(opt, $(this));
          game.start();
      }
      $(this).get(0).game = game;
      return $(this);
    };
  })(jQuery);

  $(function() {
    var CELLSIZE, CellType, clicked, copyMat, countAround, field, putCell, stopped;

    CELLSIZE = 10;
    CellType = {
      Die: 0,
      Life: 1
    };
    countAround = function(mat, cx, cy, val) {
      var ret, x, y, _i, _j, _ref, _ref1, _ref2, _ref3;

      ret = 0;
      for (y = _i = _ref = cy - 1, _ref1 = cy + 1; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; y = _ref <= _ref1 ? ++_i : --_i) {
        if (!((0 <= y && y < mat.length))) {
          continue;
        }
        for (x = _j = _ref2 = cx - 1, _ref3 = cx + 1; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; x = _ref2 <= _ref3 ? ++_j : --_j) {
          if (!((0 <= x && x < mat[y].length))) {
            continue;
          }
          if (x === cx && y === cy) {
            continue;
          }
          if (mat[y][x] === val) {
            ret++;
          }
        }
      }
      return ret;
    };
    copyMat = function(mat1, sx, sy, mat2) {
      var cell, row, x, y, _i, _len, _results;

      _results = [];
      for (y = _i = 0, _len = mat2.length; _i < _len; y = ++_i) {
        row = mat2[y];
        _results.push((function() {
          var _j, _len1, _results1;

          _results1 = [];
          for (x = _j = 0, _len1 = row.length; _j < _len1; x = ++_j) {
            cell = row[x];
            _results1.push(mat1[sy + y][sx + x] = cell);
          }
          return _results1;
        })());
      }
      return _results;
    };
    stopped = false;
    $('#controll-btn').click(function() {
      stopped = !stopped;
      return $(this).val(stopped ? 'Start' : 'Stop');
    });
    field = [];
    clicked = false;
    putCell = function(e, $canvas) {
      var left, top, x, y, _ref;

      _ref = $canvas.offset(), top = _ref.top, left = _ref.left;
      x = Math.floor((e.clientY - top) / CELLSIZE);
      y = Math.floor((e.clientX - left) / CELLSIZE);
      return field[x][y] = CellType.Life;
    };
    return $('#canvas').game({
      width: 500,
      height: 500,
      fps: 30,
      oninit: function(canvas) {
        var d, i, j, l, _i, _j, _ref, _ref1;

        for (i = _i = 0, _ref = this.height / CELLSIZE; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          field.push([]);
          for (j = _j = 0, _ref1 = this.width / CELLSIZE; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
            field[i].push(CellType.Die);
          }
        }
        l = CellType.Life;
        d = CellType.Die;
        return copyMat(field, 47, 47, [[l, l, l], [l, d, d], [d, l, d]]);
      },
      onframe: function(canvas) {
        var cell, count, ope, que, row, x, y, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _results;

        for (y = _i = 0, _len = field.length; _i < _len; y = ++_i) {
          row = field[y];
          for (x = _j = 0, _len1 = row.length; _j < _len1; x = ++_j) {
            cell = row[x];
            if (cell === CellType.Life) {
              canvas.fillRect(x * CELLSIZE, y * CELLSIZE, CELLSIZE, CELLSIZE);
            }
          }
        }
        if (!stopped) {
          que = [];
          for (y = _k = 0, _len2 = field.length; _k < _len2; y = ++_k) {
            row = field[y];
            for (x = _l = 0, _len3 = row.length; _l < _len3; x = ++_l) {
              cell = row[x];
              count = countAround(field, x, y, CellType.Life);
              if (x === 1 && y === 1) {
                console.log;
              }
              switch (cell) {
                case CellType.Life:
                  if (count <= 1 || count >= 4) {
                    que.push([y, x, CellType.Die]);
                  }
                  break;
                case CellType.Die:
                  if (count === 3) {
                    que.push([y, x, CellType.Life]);
                  }
              }
            }
          }
          _results = [];
          for (_m = 0, _len4 = que.length; _m < _len4; _m++) {
            ope = que[_m];
            _results.push(field[ope[0]][ope[1]] = ope[2]);
          }
          return _results;
        }
      }
    }).mousedown(function() {
      return clicked = true;
    }).mouseup(function() {
      return clicked = false;
    }).click(function(e) {
      return putCell(e, $(this));
    }).mousemove((function(e) {
      if (clicked) {
        return putCell(e, $(this));
      }
    }));
  });

}).call(this);
