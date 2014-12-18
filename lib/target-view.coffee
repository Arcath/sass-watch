{TextEditorView} = require 'atom-space-pen-views'
{$, View} = require 'space-pen'

module.exports =
  class TargetView extends View
    @content: ->
      @div class: 'sass-watch-target', =>
        @label "Output Path", class: 'icon icon-file-add', outlet: 'promptLabel'
        @subview 'miniEditor', new TextEditorView(mini: true)
        @div class: 'error-message', outlet: 'errorMessage'

    initialize: ->
      atom.commands.add @element,
      'core:cancel': => @detach()

    attach: (inPath, oldWatchers)->
      @panel = atom.workspace.addModalPanel(item: this)
      @path = inPath

      if oldWatchers[inPath]
        target = oldWatchers[inPath]
      else
        target = inPath.replace('.scss', '.css')

      @miniEditor.getModel().setText(target)
      @miniEditor.focus()
      @miniEditor.getModel().scrollToCursorPosition()

    detach: ->
      @panel.destroy()
      atom.workspace.getActivePane()?.activate()
