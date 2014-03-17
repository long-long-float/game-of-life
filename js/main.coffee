(($) ->
  class Game
    constructor: (opt, $canvas) ->
      @opt = $.extend {
          width: 100
          height: 100
          fps: 30
          oninit: (canvas) ->
          onframe: (canvas) ->
        }, opt
      @canvas = $canvas
        .attr('width', @opt.width).attr('height', @opt.height)
        .get(0).getContext('2d')

      @opt.oninit()

    start: ->
      return if @intervalID

      @intervalID = setInterval (=>
        old = @canvas.fillStyle
        @canvas.fillStyle = '#fff'
        @canvas.fillRect(0, 0, @opt.width, @opt.height)
        @canvas.fillStyle = old
        @opt.onframe(@canvas)
        ), 1000.0 / @opt.fps

    stop: ->
      return unless @intervalID

      clearInterval(@intervalID)
      @intervalID = null

  game = null

  $.fn.game = (opt) ->
    switch opt
      when 'start'
        game.start()
      when 'stop'
        game.stop()
      else
        game = new Game(opt, $(this))
        game.start()

    $(this).get(0).game = game

    return $(this)
)(jQuery)

$ ->
  CELLSIZE = 10
  CellType = {
    Die: 0
    Life: 1
  }

  countAround = (mat, cx, cy, val) ->
    ret = 0
    for y in [cy - 1..cy + 1]
      continue unless 0 <= y < mat.length
      for x in [cx - 1..cx + 1]
        continue unless 0 <= x < mat[y].length
        continue if x == cx and y == cy
        ret++ if mat[y][x] == val
    return ret

  copyMat = (mat1, sx, sy, mat2) ->
    for row, y in mat2
      for cell, x in row
        mat1[sy + y][sx + x] = cell

  stopped = false

  $('#controll-btn').click ->
    stopped = !stopped
    $(this).val(if stopped then 'Start' else 'Stop')

  field = []

  clicked = false

  putCell = (e, $canvas) ->
    {top, left} = $canvas.offset()
    x = Math.floor((e.clientY - top) / CELLSIZE)
    y = Math.floor((e.clientX - left) / CELLSIZE)
    field[x][y] = CellType.Life

  $('#canvas').game(
    width: 500
    height: 500
    fps: 30
    oninit: (canvas) ->
      for i in [0...@height / CELLSIZE]
        field.push []
        for j in [0...@width / CELLSIZE]
          field[i].push CellType.Die
      
      l = CellType.Life
      d = CellType.Die
      copyMat(field, 47, 47, [
        [l, l, l]
        [l, d, d]
        [d, l, d]
        ])
    onframe: (canvas) ->
      for row, y in field
        for cell, x in row
          if cell == CellType.Life
            canvas.fillRect(x * CELLSIZE, y * CELLSIZE, CELLSIZE, CELLSIZE)

      unless stopped
        que = []
        for row, y in field
          for cell, x in row
            count = countAround(field, x, y, CellType.Life)
            if x == 1 and y == 1
              console.log
            switch cell
              when CellType.Life
                if count <= 1 or count >= 4
                  que.push [y, x, CellType.Die]
              when CellType.Die
                if count == 3
                  que.push [y, x, CellType.Life]
        for ope in que
          field[ope[0]][ope[1]] = ope[2]
    ).mousedown ->
      clicked = true
    .mouseup ->
      clicked = false
    .click (e) ->
      putCell(e, $(this))
    .mousemove ((e) ->
      if clicked
        putCell(e, $(this))
    )