_ = require 'underscore-plus'

ListView = require './list-view'
TargetView = require './target-view'
Watcher = require './watcher'


module.exports =
  listView: null
  targetView: null
  nextEditor: null
  watchers: {}

  activate: ->
    atom.commands.add 'atom-workspace', 'sass-watch:watch', => @watchFile()
    atom.commands.add 'atom-workspace', 'sass-watch:list', => @listWatchers()

    @targetView = new TargetView()
    atom.commands.add @targetView.element,
      'core:confirm': => @startWatch(@targetView.path, @targetView.miniEditor.getText())

    @listView = new ListView()

  deactivate: ->
    _.each @watchers, (watcher) -> watcher.end()

  watchFile: ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path

    @nextEditor = editor

    if filePath
      @targetView.attach(filePath)
    else
      atom.notifications.addError('SASS Watch', {detail: 'Unable to find the path for your current file. \r\nThis shouldn\'t happen please open an issue on the repo.'})

  startWatch: (inPath, outPath) ->
    unless @watchers[inPath]
      @watchers[inPath] = new Watcher(inPath, outPath, @nextEditor)
    else
      atom.notifications.addInfo('SASS Watch', {detail: 'Already compling ' + inPath + ' to ' + outPath})

    @targetView.detach()

  listWatchers: ->
    @listView.show(@watchers)
