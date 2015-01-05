path = require 'path'
childProcess = require 'child_process'

module.exports =
  class Watcher
    inPath: null
    outPath: null
    binary: null
    fileName: null
    editor: null
    disposable: null

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

    renderFile: ->
      childProcess.exec [@binary, @quotePath(@inPath), @quotePath(@outPath)].join(' '), {env: {'PATH': process.env + ":" + atom.config.get('sass-watch.nodePath')}}, (error, stdout, stderr) => @handleExec(error, stdout, stderr)

    handleExec: (error, stdout, stderr) ->
      if error
        atom.notifications.addError('SASS Compile Failed', {detail: error.message})
      else
        atom.notifications.addSuccess('Converted to CSS', {detail: @outPath})

    getFileName: ->
      @inPath.split("/").slice(-1).pop()

    stop: ->
      @disposable?.dispose()

    editorClosed: ->
      @stop()
      atom.notifications.addInfo('Stopped Watching File', {detail: @inPath})
      SassWatch = atom.packages.getActivePackage('sass-watch')?.mainModule
      delete SassWatch?.watchers[@inPath]

    updateOutput: (newOutput) ->
      @outPath = newOutput

    quotePath: (path) ->
      return ['"', path, '"'].join('')
