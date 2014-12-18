path = require 'path'
childProcess = require 'child_process'

module.exports =
  class Watcher
    inPath: null
    outPath: null
    binary: null
    process: null
    fileName: null
    editor: null
    disposable: null

    nextMessage: null

    constructor: (inPath, outPath, editor) ->
      @inPath = inPath
      @outPath = outPath
      @nextMessage = outPath
      @fileName = @getFileName()
      @editor = editor
      @binary = path.join(__dirname, "..", "node_modules", ".bin", "node-sass")

      @start()

    start: ->
      atom.notifications.addInfo('Watching File!', {detail: 'Source: ' + @inPath + '\r\nDestination: ' + @outPath})

      @renderFile()

      @disposable = @editor.buffer.emitter.on 'did-save', => @renderFile()

      @editor.emitter.on 'did-destroy', => @editorClosed()

    end: ->
      @disposable?.dispose()
      @process?.kill('SIGTERM')

    renderFile: ->
      @process = childProcess.spawn @binary, [@inPath, @outPath]

      @process.stdout.on 'data', (data) ->
        console.log data

      @process.on 'exit', => @sendMessage()

    addToMessage: (data) ->
      console.log 'adding data'
      console.log data
      @nextMessage += data

    sendMessage: (code) ->
      atom.notifications.addSuccess('Converted to CSS', {detail: @nextMessage})
      @nextMessage = @outPath

    getFileName: ->
      @inPath.split("/").slice(-1).pop()

    stop: ->
      @disposable?.dispose()

    editorClosed: ->
      @stop()
      atom.notifications.addInfo('Stopped Watching File', {detail: @inPath})
      SassWatch = atom.packages.getActivePackage('sass-watch')?.mainModule
      delete SassWatch?.watchers[@inPath]
