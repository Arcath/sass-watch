path = require 'path'
childProcess = require 'child_process'

module.exports =
  class Watcher
    inPath: null
    outPath: null
    binary: null
    fileName: null
    editor: null
    disposables: []
    imports: []

    constructor: (inPath, outPath, editor) ->
      @inPath = inPath
      @outPath = outPath
      @nextMessage = outPath
      @fileName = @getFileName()
      @editor = editor
      @binary = path.join(__dirname, "..", "node_modules", "node-sass", "bin", "node-sass")

      @start()

    start: ->
      atom.notifications.addInfo('Watching File!', {detail: 'Source: ' + @inPath + '\r\nDestination: ' + @outPath})

      @renderFile()

      @disposables.push @editor.buffer.emitter.on 'did-save', => @renderFile()

      @editor.emitter.on 'did-destroy', => @editorClosed()

    end: ->
      for disposable in @disposables
        disposable.dispose()

    renderFile: ->
      @findImports()
      outDir = path.dirname @outPath
      outFile = path.basename @outPath
      childProcess.exec [@quotePath(atom.config.get('sass-watch.nodeBinary')), @quotePath(@binary), @quotePath(@inPath),  "-o", outDir, outFile].join(' '), {env: {'PATH': process.env + ":" + atom.config.get('sass-watch.nodePath')}}, (error, stdout, stderr) => @handleExec(error, stdout, stderr)

    handleExec: (error, stdout, stderr) ->
      if error
        atom.notifications.addError('SASS Compile Failed', {detail: error.message})
      else
        atom.notifications.addSuccess('Converted to CSS', {detail: @outPath})

    getFileName: ->
      @inPath.split("/").slice(-1).pop()

    editorClosed: ->
      @end()
      atom.notifications.addInfo('Stopped Watching File', {detail: @inPath})
      SassWatch = atom.packages.getActivePackage('sass-watch')?.mainModule
      delete SassWatch?.watchers[@inPath]
      delete SassWatch?.imports[@inPath]

    updateOutput: (newOutput) ->
      @outPath = newOutput

    quotePath: (path) ->
      return ['"', path, '"'].join('')

    findImports: ->
      imports = @scan(@editor.buffer.cachedText, /@import ['|"](.*?)['|"];/g)
      for sassImport in imports
        importPath = path.join(@inPath, '../', sassImport[0])
        @imports.push importPath if @imports.indexOf(importPath) == -1

      SassWatch = atom.packages.getActivePackage('sass-watch')?.mainModule
      for childFile in @imports
        SassWatch?.imports[childFile] = @inPath

    scan: (string, pattern) ->
      matches = []
      results = []
      while matches = pattern.exec(string)
        matches.shift();
        results.push(matches)

      return results

    importWatch: (editor) ->
      @disposables.push editor.buffer.emitter.on 'did-save', => @renderFile()
