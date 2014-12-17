{$, $$} = require 'space-pen'
{SelectListView} = require 'atom-space-pen-views'

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
          @div class: 'primary-line', watcher.inPath
          @div class: 'secondary-line', watcher.outPath

    cancelled: -> @detach()

    confirmed: (watcher) ->
      console.log watcher

    getFilterKey: ->
      'inPath'
