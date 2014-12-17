path = require 'path'
childProcess = require 'child_process'
fs = require 'fs-plus'

module.exports =
  class Watcher
    inPath: null
    outPath: null
    binary: null
    process: null
    fileName: null
    fsw: null

    nextMessage: null

    constructor: (inPath, outPath) ->
      @inPath = inPath
      @outPath = outPath
      @nextMessage = outPath
      @fileName = @getFileName()
      @binary = path.join(__dirname, "..", "node_modules", ".bin", "node-sass")

      @start()

    start: ->
      atom.notifications.addInfo('Watching File!', {detail: 'Source: ' + @inPath + '\r\nDestination: ' + @outPath})

      @renderFile()

      @fsw = fs.watch(@inPath, => @renderFile())

    end: ->
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
      @fsw.close()
