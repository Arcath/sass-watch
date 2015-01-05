path = require 'path'
fs = require 'fs-plus'

{$, $$} = require 'atom-space-pen-views'

describe 'SASS Watch', ->
  [activationPromise, editor, editorView, targetView] = []

  beforeEach ->
    atom.project.setPaths([path.join(__dirname, 'samples with spaces')])

    workspaceElement = atom.views.getView(atom.workspace)

    waitsForPromise ->
      atom.workspace.open 'example.scss'

    runs ->
      jasmine.attachToDOM(workspaceElement)
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)

      activationPromise = atom.packages.activatePackage('sass-watch')
      activationPromise.fail (reason) ->
        throw reason

  it 'should prompt for a target', ->
    atom.commands.dispatch editorView, 'sass-watch:watch'

    waitsForPromise ->
      activationPromise

    runs ->
      targetView = $(atom.workspace.getModalPanels()[0].getItem()).view()
      expect(targetView).toBeVisible()
      expect(targetView.miniEditor.getText()).not.toBe ''

  it 'should suggest the same file with .css', ->
    atom.commands.dispatch editorView, 'sass-watch:watch'

    waitsForPromise ->
      activationPromise

    runs ->
      expectedPath = path.join(__dirname, 'samples with spaces', 'example.css')
      targetView = $(atom.workspace.getModalPanels()[0].getItem()).view()
      expect(targetView.miniEditor.getText()).toBe expectedPath

  it 'should respond to cancel', ->
    atom.commands.dispatch editorView, 'sass-watch:watch'

    waitsForPromise ->
      activationPromise

    runs ->
      targetView = $(atom.workspace.getModalPanels()[0].getItem()).view()
      expect(targetView).toBeVisible()

      atom.commands.dispatch targetView.element, 'core:cancel'

      expect(targetView).not.toBeVisible()

  it 'should confirm the output', ->
    atom.commands.dispatch editorView, 'sass-watch:watch'

    waitsForPromise ->
      activationPromise

    runs ->
      sourcePath = path.join(__dirname, 'samples with spaces', 'example.scss')
      targetView = $(atom.workspace.getModalPanels()[0].getItem()).view()
      expect(targetView).toBeVisible()

      atom.commands.dispatch targetView.element, 'core:confirm'

      expect(targetView).not.toBeVisible()
      mainModule = atom.packages.getActivePackage('sass-watch').mainModule
      expect(mainModule.watchers[sourcePath]).not.toBe null

  it 'should add a warning if you are asking it to watch a non SASS file', ->
    waitsForPromise ->
      atom.workspace.open( path.join(__dirname, '..', 'lib', 'sass-watch.coffee') )

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)

      notifcationsCount = atom.notifications.notifications.length

      atom.commands.dispatch editorView, 'sass-watch:watch'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.notifications.notifications.length).toBe (notifcationsCount + 1)
        notification = atom.notifications.notifications.reverse()[0]
        expect(notification.type).toBe 'warning'
        expect(notification.options.detail).toBe 'coffee is not a SASS file'


  describe 'The Watcher', ->
    it 'should store the in/out paths', ->
      atom.commands.dispatch editorView, 'sass-watch:watch'

      waitsForPromise ->
        activationPromise

      runs ->
        sourcePath = path.join(__dirname, 'samples with spaces', 'example.scss')
        expectedPath = path.join(__dirname, 'samples with spaces', 'example.css')
        mainModule = atom.packages.getActivePackage('sass-watch').mainModule
        watcher = mainModule.watchers[sourcePath]
        expect(watcher.inPath).toBe sourcePath
        expect(watcher.outPath).toBe expectedPath
        expect(watcher.fileName).toBe 'example.scss'

    it 'should let you update the output', ->
      atom.commands.dispatch editorView, 'sass-watch:watch'

      waitsForPromise ->
        activationPromise

      runs ->
        sourcePath = path.join(__dirname, 'samples with spaces', 'example.scss')
        expectedPath = path.join(__dirname, 'samples with spaces', 'example.css')
        mainModule = atom.packages.getActivePackage('sass-watch').mainModule
        watcher = mainModule.watchers[sourcePath]

        expect(watcher.outPath).toBe expectedPath
        watcher.updateOutput('/foo')
        expect(watcher.outPath).toBe '/foo'
        watcher.updateOutput(expectedPath)

    it 'should render the file', ->
      atom.commands.dispatch editorView, 'sass-watch:watch'

      waitsForPromise ->
        activationPromise

      runs ->
        sourcePath = path.join(__dirname, 'samples with spaces', 'example.scss')
        expectedPath = path.join(__dirname, 'samples with spaces', 'example.css')
        mainModule = atom.packages.getActivePackage('sass-watch').mainModule
        watcher = mainModule.watchers[sourcePath]

        expect(watcher.outPath).toBe expectedPath
        testPath = path.join(__dirname, 'samples with spaces', 'test.css')
        watcher.updateOutput(testPath)

        watcher.renderFile()

        waitsFor ->
          fs.existsSync(testPath)

        runs ->
          expect(fs.existsSync(testPath)).toBe true
          fs.unlinkSync(testPath)

          watcher.updateOutput(expectedPath)


  describe 'The List', ->
    it 'should appear', ->
      atom.commands.dispatch editorView, 'sass-watch:list'

      waitsForPromise ->
        activationPromise

      runs ->
        listView = $(atom.workspace.getModalPanels()[0].getItem()).view()
        expect(listView).toBeVisible()

    it 'should contain watchers', ->
      atom.commands.dispatch editorView, 'sass-watch:list'

      waitsForPromise ->
        activationPromise

      runs ->
        sourcePath = path.join(__dirname, 'samples with spaces', 'example.scss')
        listView = $(atom.workspace.getModalPanels()[0].getItem()).view()
        expect(listView.items[0].inPath).toBe sourcePath
