{$, View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'

module.exports =
  class WatcherView extends View
    @content: (watcher) ->
      @div class: 'sass-watcher-view', =>
        @h1 class: 'section-heading', watcher.fileName
        @ul class: 'list-group', =>
          @li class: 'list-item', =>
            @label class: 'icon icon-file-text', 'Source'
            @span watcher.inPath
          @li class: 'list-item', =>
            @label class: 'icon icon-file-text', 'Output'
            @subview 'outputEditor', new TextEditorView(mini: true)
        @div class: 'block', =>
          @div class: 'btn-group', =>
            @button class: 'btn', click: 'updateWatcher', 'Update Watcher'
            @button class: 'btn', click: 'stopWatcher', 'Stop Watching'
            @button class: 'btn', click: 'detach', 'Close'

    initialize: (watcher) ->
      @watcher = watcher
      @panel = atom.workspace.addModalPanel(item: this)
      @outputEditor.getModel().setText(watcher.outPath)

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

    updateWatcher: ->
      SassWatch = atom.packages.getActivePackage('sass-watch').mainModule
      SassWatch.updateWatcher(@watcher.inPath, @outputEditor.getText())
      @detach()
