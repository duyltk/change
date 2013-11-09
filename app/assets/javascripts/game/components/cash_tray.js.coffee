Crafty.c 'CashTray',

  columns: [580, 668, 756, 844]
  rows:
    bills: 278
    coins: 416
  _piles: {}

  init: ->
    @requires('2D, DOM, Image, Tween')
    .image(Game.images.cashTrayOpen)
    .attr(x: 560, y: 254, z: 5)

    _.each Game.DENOMINATIONS, (denomination) =>
      @_createDenominationPile(denomination)

    @

  open: ->
    @attr(y: 50)
    .tween({y: 254}, 20)

  cash: (cash) ->
    @_cash.off() if @_cash?
    @_cash = cash
    _.each Game.DENOMINATIONS, (denomination) =>
      pile = @_piles[denomination]
      pile.amount(cash.amountOf(denomination))
      @_cash.on("change:#{denomination}", => pile.amount(@_cash.amountOf(denomination)))
    @

  _createDenominationPile: (denomination)->
    pile = Crafty.e('TrayDenominationPile').denomination(denomination)

    if Game.isBill(denomination)
      pile.attr(x: @columns[Game.DENOMINATIONS.indexOf(denomination) - Game.DENOMINATIONS.indexOf(Game.dollar)], y: @rows.bills)
    else
      pile.attr(x: @columns[Game.DENOMINATIONS.indexOf(denomination)], y: @rows.coins)
    pile.bind('Click', => @trigger('DenominationClick', denomination))
    @_piles[denomination] = pile

    @attach(pile)