{SelectListView} = require 'atom-space-pen-views'

module.exports =
  class BrunchMenu extends SelectListView
    menuItems: []
    afterConfirmed: Function.prototype

    constructor: (options) ->
      super()
      @afterConfirmed = options.afterConfirmed || @afterConfirmed
      @menuItems = options.menuItems || @menuItems

    showModalPanel: (type) ->
      @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
      @addClass('overlay from-top')
      @setItems(@menuItems)
      @panel.show()
      @focusFilterEditor()

    viewForItem: (item) ->
      if item.selected
        "<li data-selected='true'>#{item.description}</li>"
      else
        "<li>#{item.description}</li>"

    confirmed: (item) ->
      @afterConfirmed.apply(@, [item])
      @cancelled()

    cancelled: ->
      @panel.hide()
