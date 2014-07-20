EditCodeBlocksView = require './edit-code-blocks-view'
url = require 'url'

PROTOCOL = 'ecb:'
NUM_POSSIBLE_VIEWS = 5

module.exports =

  activate: (state) ->
    for index in [1..NUM_POSSIBLE_VIEWS]
      do (index) =>
        atom.workspaceView.command "edit-code-blocks:capture#{index}",
          (e) => @capture(e, index)
    atom.workspace.registerOpener (uri) ->
      try
        {protocol, host, pathname} = url.parse(uri)
      catch err
        return
      return unless protocol is PROTOCOL
      new EditCodeBlocksView protocol: protocol, host: host

  capture: (e, captureIndex) ->
    editor = atom.workspace.getActiveEditor()

    # Only capture if text is selected, else defer to next binding
    if !editor || editor.getSelectedText() == ''
      e.abortKeyBinding()
      return

    uri = "#{PROTOCOL}//#{captureIndex}"

    pane = atom.workspace.paneForUri uri
    if pane
      view = pane.itemForUri uri
      view.addPartial editor
    else
      atom.workspace.open uri, split: 'right', searchAllPanes: true
      .done (view) ->
        view.addPartial editor
