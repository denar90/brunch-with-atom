{SelectListView} = require 'atom-space-pen-views'

module.exports =
  class BrunchMenu extends SelectListView
    skeletons: []
    afterConfirmed: Function.prototype

    constructor: (options) ->
      super()
      @afterConfirmed = options.afterConfirmed || @afterConfirmed
      @skeletons = options.skeletons || @skeletons

    showModalPanel: (type) ->
      @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
      @addClass('overlay from-top')
      @setItems(@skeletons)
      @panel.show()
      @focusFilterEditor()

    viewForItem: (item) ->
      "<li>#{item.description}</li>"

    confirmed: (item) ->
      @afterConfirmed.apply(@, [item])
      @cancelled()

    cancelled: ->
      @panel.hide()
