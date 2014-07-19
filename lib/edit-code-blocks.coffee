EditCodeBlocksView = require './edit-code-blocks-view'
url = require 'url'

PROTOCOL = 'ecb:'

module.exports =
  editCodeBlocksView: null

  activate: (state) ->
    atom.workspaceView.command 'edit-code-blocks:capture', @capture
    atom.workspace.registerOpener (uri) ->
      try
        {protocol, host, pathname} = url.parse(uri)
      catch err
        return
      return unless protocol is PROTOCOL
      new EditCodeBlocksView host: host, pathname: pathname

  capture: ->
    editor = atom.workspace.getActiveEditor()
    uri = "#{PROTOCOL}//ecb"

    pane = atom.workspace.paneForUri uri
    if pane
      view = pane.itemForUri uri
      view.addPartial editor
    else
      atom.workspace.open uri, split: 'right', searchAllPanes: true
      .done (view) ->
        view.addPartial editor

  # deactivate: ->
  #   @editCodeBlocksView.destroy()
  #
  # serialize: ->
  #   editCodeBlocksViewState: @editCodeBlocksView.serialize()
