{WorkspaceView} = require 'atom'
EditCodeBlocks = require '../lib/edit-code-blocks'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "EditCodeBlocks", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('edit-code-blocks')

  describe "when the edit-code-blocks:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.edit-code-blocks')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'edit-code-blocks:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.edit-code-blocks')).toExist()
        atom.workspaceView.trigger 'edit-code-blocks:toggle'
        expect(atom.workspaceView.find('.edit-code-blocks')).not.toExist()
