(($) ->
  class Game
    constructor: (opt, $canvas) ->
      @opt = $.extend {
          width: 100
          height: 100
          fps: 30
          background: '#fff'
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
        @canvas.fillStyle = @opt.background
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
  CELL_DIE = 0
  Cell2Color = [
    null #die
    '#00ff00' #green
    '#ff0000' #red
    '#0000ff' #blue
  ]

  countsAround = (mat, cx, cy) ->
    ret = {}
    for y in [cy - 1..cy + 1]
      continue unless 0 <= y < mat.length
      for x in [cx - 1..cx + 1]
        continue unless 0 <= x < mat[y].length
        continue if x == cx and y == cy

        current = mat[y][x]
        ret[current] ||= 0
        ret[current]++
    return ret

  countAround = (mat, cx, cy, val) ->
    countsAround(mat, cx, cy)[val] ? 0

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

  console.log countsAround([
    [3, 2, 1]
    [1, 2, 3]
    [2, 2, 3]
    ], 1, 1)

  putCell = (e, $canvas) ->
    {top, left} = $canvas.offset()
    x = Math.floor((e.clientY - top) / CELLSIZE)
    y = Math.floor((e.clientX - left) / CELLSIZE)
    field[x][y] = { 1: 1, 3: CELL_DIE }[e.which]

  $('#canvas').game(
    width: 500
    height: 500
    fps: 2
    background: '#000'
    oninit: (canvas) ->
      for i in [0...@height / CELLSIZE]
        field.push []
        for j in [0...@width / CELLSIZE]
          field[i].push CELL_DIE
      
    onframe: (canvas) ->
      for row, y in field
        for cell, x in row
          canvas.strokeStyle = '#005500'
          canvas.strokeRect(x * CELLSIZE, y * CELLSIZE, CELLSIZE, CELLSIZE)
          if cell != CELL_DIE
            canvas.fillStyle = '#00ff00'
            canvas.fillRect(x * CELLSIZE, y * CELLSIZE, CELLSIZE, CELLSIZE)

      unless stopped
        que = []
        for row, y in field
          for cell, x in row
            if cell != CELL_DIE #live cell
              count = countAround(field, x, y, cell)
              if count <= 1 or count >= 4
                que.push [y, x, CELL_DIE]
            else #die cell
              counts = countsAround(field, x, y)
              for cel, count of counts
                if count == 3
                  que.push [y, x, parseInt(cel)]
        for ope in que
          field[ope[0]][ope[1]] = ope[2]
    ).mousedown ->
      clicked = true
    .mouseup ->
      clicked = false
    .click (e) ->
      putCell(e, $(this))
    .mousemove (e) ->
      if clicked
        putCell(e, $(this))
    .bind 'contextmenu', (e) ->
      putCell(e, $(this))
      return false