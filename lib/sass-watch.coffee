_ = require 'underscore-plus'
cson = require 'season'
path = require 'path'
fs = require 'fs-plus'

ListView = require './list-view'
TargetView = require './target-view'
Watcher = require './watcher'


module.exports =
  config:
    nodeBinary:
      type: 'string'
      default: path.join process.execPath, '../', 'resources', 'app', 'apm', 'bin', 'node'

  listView: null
  targetView: null
  nextEditor: null
  watchers: {}
  oldWatchers: {}
  imports: {}

  activate: ->
    atom.notifications.addInfo('sass-watch', {detail: 'sass-watch is no longer supported! Please use compile-watch which contains the same functionality & more!'})
    atom.commands.add 'atom-workspace', 'sass-watch:watch', => @watchFile()
    atom.commands.add 'atom-workspace', 'sass-watch:list', => @listWatchers()

    @targetView = new TargetView()
    atom.commands.add @targetView.element,
      'core:confirm': => @startWatch(@targetView.path, @targetView.miniEditor.getText())

    @listView = new ListView()

    @loadOldWatchers()

  deactivate: ->
    filePath = path.join(__dirname,"..", "previous_watchers.cson")

    _.each @watchers, (watcher) -> watcher.end()
    cson.writeFileSync(filePath, @oldWatchers)

  watchFile: ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path

    @nextEditor = editor

    if filePath
      fileType = filePath.split(".").reverse()[0]

      if fileType == "sass" or fileType == "scss"
        @targetView.attach(filePath, @oldWatchers)
      else
        atom.notifications.addWarning('Sass Watch', {detail: fileType + ' is not a SASS file'})

    else
      atom.notifications.addError('SASS Watch', {detail: 'Unable to find the path for your current file. \r\nThis shouldn\'t happen please open an issue on the repo.'})

  startWatch: (inPath, outPath) ->
    unless @watchers[inPath]
      @watchers[inPath] = new Watcher(inPath, outPath, @nextEditor)
      @oldWatchers[inPath] = outPath
    else
      atom.notifications.addInfo('SASS Watch', {detail: 'Already compling ' + inPath + ' to ' + outPath})

    @targetView.detach()

  listWatchers: ->
    @listView.show(@watchers)

  loadOldWatchers: ->
    filePath = path.join(__dirname,"..", "previous_watchers.cson")
    if fs.existsSync(filePath)
      @oldWatchers = cson.readFileSync(filePath)

    atom.workspace.observeTextEditors (editor) => @didOpenFile(editor)

  didOpenFile: (editor) ->
    file = editor?.buffer.file
    filePath = file?.path

    if @oldWatchers[filePath]
      atom.notifications.addInfo('Watch Again?', {detail: 'The file\r\n' + filePath + '\r\nhas been watched before if you watch it again the target\r\nwill default to\r\n' + @oldWatchers[filePath]})

    if @imports[filePath]
      atom.notifications.addInfo('Imported in another file', {detail: 'The file\r\n' + filePath + '\r\nis imported in\r\n' + @imports[filePath]})
      @watchers[@imports[filePath]].importWatch(editor)

  updateWatcher: (path, newOutput) ->
    unless newOutput == @watchers[path].outPath
      @watchers[path].updateOutput newOutput
      @oldWatchers[path] = newOutput
      atom.notifications.addInfo('Watcher Updated', {detail: path + ' will now compile to ' + newOutput})
