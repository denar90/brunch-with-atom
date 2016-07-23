{SelectListView} = require 'atom-space-pen-views'
_ = require 'underscore'

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
      @setItems(@getMenuItemsDescription())
      @panel.show()
      @focusFilterEditor()

    viewForItem: (item) ->
      menuItem = @getMenuItemByDescription(item)
      if menuItem.selected
        "<li data-selected='true'>#{menuItem.description}</li>"
      else
        "<li>#{menuItem.description}</li>"

    confirmed: (item) ->
      menuItem = @getMenuItemByDescription(item)
      @afterConfirmed.apply(@, [menuItem])
      @cancelled()

    cancelled: ->
      @panel.hide()

    getMenuItemsDescription: ->
      _.map @menuItems, (item, index) ->
        item.description

    getMenuItemByDescription: (description) ->
      _.findWhere @menuItems, {description: description}
