{$, View} = require 'space-pen'

module.exports =
  class WatcherView extends View
    @content: (watcher) ->
      @div class: 'sass-watcher-view', =>
        @div class: 'text-highlight', watcher.fileName
        @div =>
          @p watcher.inPath
          @p watcher.outPath
        @div class: 'block', =>
          @div class: 'btn-group', =>
            @button class: 'btn', click: 'stopWatcher', 'Stop Watching'
            @button class: 'btn', click: 'detach', 'Close'

    initialize: (watcher) ->
      @watcher = watcher
      @panel = atom.workspace.addModalPanel(item: this)

      atom.commands.add @element,
        'core:cancel': => @detach()

    detach: ->
      @panel.destroy()
      atom.workspace.getActivePane()?.activate()

    stopWatcher: ->
      @detach()
      SassWatch = atom.packages.getActivePackage('sass-watch').mainModule
      SassWatch.watchers[@watcher.inPath].stop()
      delete SassWatch.watchers[@watcher.inPath]
