(($) ->
  class Game
    constructor: (opt, $canvas) ->
      @opt = $.extend {
          width: 100
          height: 100
          fps: 30
          oninit: (canvas) ->
          onframe: (canvas) ->
          onclick: (event) ->
        }, opt
      @canvas = $canvas
        .attr('width', @opt.width).attr('height', @opt.height)
        .get(0).getContext('2d')

      $canvas.click (e) ->
        @opt.onclick(e)

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

  $('#start-btn').click ->
    $('#canvas').game('start')

  $('#stop-btn').click ->
    $('#canvas').game('stop')

  $('#canvas').game(
    width: 200
    height: 200
    fps: 30
    oninit: (canvas) ->
      @field = []
      for i in [0...@height / CELLSIZE]
        @field.push []
        for j in [0...@width / CELLSIZE]
          @field[i].push CellType.Die
      
      l = CellType.Life
      d = CellType.Die
      copyMat(@field, 15, 15, [
        [l, l, l]
        [l, d, d]
        [d, l, d]
        ])
    onframe: (canvas) ->
      for row, y in @field
        for cell, x in row
          if cell == CellType.Life
            canvas.fillRect(x * CELLSIZE, y * CELLSIZE, CELLSIZE, CELLSIZE)

      que = []
      for row, y in @field
        for cell, x in row
          count = countAround(@field, x, y, CellType.Life)
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
        @field[ope[0]][ope[1]] = ope[2]
    onclick: (e) ->
      @field[Math.floor(e.clientY / CELLSIZE)][Math.floor(e.clientX / CELLSIZE)] = CellType.Life
    )