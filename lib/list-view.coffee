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
        @li watcher.fileName

    cancelled: -> @detach()

    confirmed: (watcher) ->
      @watcherView = new WatcherView(watcher)

    getFilterKey: ->
      'inPath'
