{$, $$} = require 'space-pen'
{SelectListView} = require 'atom-space-pen-views'
WatcherView = require './watcher-view'

module.exports =
  class ListView extends SelectListView
    show: (watchers) ->
      @panel = atom.workspace.addModalPanel(item: this)
      arr = []

      $.each(watchers, (watcher) -> arr.push watchers[watcher])

      @setItems(arr)
      @focusFilterEditor()

    detach: ->
      @panel.destroy()
      atom.workspace?.getActivePane()?.activate()

    viewForItem: (watcher) ->
      $$ ->
        @li class: 'two-lines', =>
          @div class: 'primary-line', watcher.fileName
          @div class: 'secondary-line', watcher.inPath

    cancelled: -> @detach()

    confirmed: (watcher) ->
      @watcherView = new WatcherView(watcher)

    getFilterKey: ->
      'inPath'
