path = require 'path'
fs = require 'fs-plus'

{$, $$} = require 'atom-space-pen-views'

describe 'SASS Watch', ->
  [activationPromise, editor, editorView, targetView] = []

  beforeEach ->
    atom.project.setPaths([path.join(__dirname, 'samples')])

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
      expectedPath = path.join(__dirname, 'samples', 'example.css')
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
      sourcePath = path.join(__dirname, 'samples', 'example.scss')
      targetView = $(atom.workspace.getModalPanels()[0].getItem()).view()
      expect(targetView).toBeVisible()

      atom.commands.dispatch targetView.element, 'core:confirm'

      expect(targetView).not.toBeVisible()
      mainModule = atom.packages.getActivePackage('sass-watch').mainModule
      expect(mainModule.watchers[sourcePath]).not.toBe null

  describe 'The Watcher', ->
    it 'should store the in/out paths', ->
      atom.commands.dispatch editorView, 'sass-watch:watch'

      waitsForPromise ->
        activationPromise

      runs ->
        sourcePath = path.join(__dirname, 'samples', 'example.scss')
        expectedPath = path.join(__dirname, 'samples', 'example.css')
        mainModule = atom.packages.getActivePackage('sass-watch').mainModule
        watcher = mainModule.watchers[sourcePath]
        expect(watcher.inPath).toBe sourcePath
        expect(watcher.outPath).toBe expectedPath
        expect(watcher.fileName).toBe 'example.scss'


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
        sourcePath = path.join(__dirname, 'samples', 'example.scss')
        listView = $(atom.workspace.getModalPanels()[0].getItem()).view()
        expect(listView.items[0].inPath).toBe sourcePath
