Crafty.scene 'game', ->
  Crafty.background('white')
  soundtrack = new Game.Soundtrack()
  soundtrack.start()

  # initialization

  ui =
    background:     Crafty.e('2D, DOM, background').attr(x: 0, y:0, w: Config.window.width, h: Config.window.height)
    table:          Crafty.e('2D, DOM, table').attr(x: 0, y:(Config.window.height - 450), w: Config.window.width, h: 450)
    ticker:         Crafty.e('Ticker').attr(x:20, y: 15)
    customerPrice:  Crafty.e('CustomerPrice').attr(x:20, y:200)
    customerPaid:   Crafty.e('CashButtons').attr(x: 160)
    cashOut:        Crafty.e('CashButtons').attr(x: 260)
    cashInRegister: Crafty.e('CashButtons').attr(x: 360)
    soundControls:  Crafty.e('SoundControls').attr(x: 500, y: 20).soundtrack(soundtrack)
    submitButton:   Crafty.e('2D, DOM, Mouse, Color, Text').attr(x: 160, y: 420, w: 260, h: 40).color('#9482BA').textFont(size: '16px/40px').textColor('#FFFFFF').css('text-align': 'center').text('Submit')
    feedbackLabel:  Crafty.e('2D, DOM, Text, Tween').attr(x: 160, y: 470, w: 260, h: 40).textFont(size: '16px').css('text-align': 'center')

    shadow:         Crafty.e('2D, DOM, Image').image(Game.images.shadow).attr(x: 140, y: 180)
    hand1:          Crafty.e('2D, DOM, Image').image(Game.images.hand1).attr(x: -100, y: 250)
    hand2:          Crafty.e('2D, DOM, Image').image(Game.images.hand2).attr(x: 360, y: 440)
    hand3:          Crafty.e('2D, DOM, Image').image(Game.images.hand3).attr(x: 854, y: 333)

  ui.shadow.alpha = 0.5
  window.ui = ui

  currentCustomer = null
  player = new Game.Player()

  # event bindings

  ui.cashOut.bind('ButtonClick', (denomination) ->
    player.get('cashOut').subtract(denomination)
    player.get('cashInRegister').add(denomination)
    Game.sfx.playDenomination(denomination)
  )

  ui.cashInRegister.bind('ButtonClick', (denomination) ->
    player.get('cashInRegister').subtract(denomination)
    player.get('cashOut').add(denomination)
    Game.sfx.playDenomination(denomination)
  )

  @bind('KeyDown', (ev) -> submitRound() if ev.key == Crafty.keys[Config.input.submit])
  ui.submitButton.bind('Click', -> submitRound())

  # methods

  submitRound = ->
    difference = Math.abs(currentCustomer.correctChange() - player.get('cashOut').value())
    text = "GREAT!"
    if difference > 0
      text = "You were off by #{difference.toMoneyString()}"
    ui.feedbackLabel.text(text).attr(alpha: 1).tween({alpha: 0}, 60)

    player.get('cashInRegister').merge(currentCustomer.get('paid'))
    player.set('cashOut', new Game.Cash())
    Game.sfx.playRegisterOpen()
    generateNewRound()

  generateNewRound = ->
    currentCustomer = new Game.Customer()
    ui.customerPrice.customer(currentCustomer)
    ui.customerPaid.cash(currentCustomer.get('paid'))
    ui.cashOut.cash(player.get('cashOut'))
    Game.sfx.playRegisterClose()

  # run

  ui.cashInRegister.cash(player.get('cashInRegister'))
  generateNewRound()