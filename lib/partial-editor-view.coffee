{EditorView, View} = require 'atom'

# If scrolling, will revert to partial position after SNAP_TIMEOUT ms
SNAP_TIMEOUT = 1000

# End column of screen row range
MAX_LINE_LENGTH = 1000

# /foo/bar/file.coffee -> file.coffee
getTitleFromUri = (uri) ->
  tokens = uri.split '/'
  tokens[tokens.length - 1]

blockCursorIf = (editor, fn, condition) ->
  orig = editor[fn].bind(editor)
  editor[fn] = ->
    orig() unless condition editor.getCursorScreenRow()

markerTopPx = (marker, editorView) ->
  bufferPos = marker.getTailBufferPosition()
  pixelPos = editorView.pixelPositionForBufferPosition bufferPos
  pixelPos.top

markerHeightPx = (marker, editorView) ->
  range = marker.bufferMarker.range
  heightInLines = range.end.row - range.start.row + 1
  heightInLines * editorView.lineHeight

# vScrollMargin determines when to start scrolling on cursor movements
createEditorView = (editor) ->
  view = new EditorView editor
  view.vScrollMargin = 0
  view

module.exports =
class PartialEditorView extends View

  @content: ->
    @div class: 'partial-editor tool-panel panel-bottom', =>
      @div class: 'inset-panel', =>
        @div class: 'panel-heading', =>
          @div class: 'btn-toolbar pull-right', =>
            @button class: 'btn', outlet: 'goEl'
          @span class: 'pev-title', outlet: 'titleEl'
        @div class: 'panel-body padding', =>
          @div class: 'item-views', outlet: 'editorEl'

  initialize: (@editor, screenRowRange) ->
    range = [[screenRowRange[0], 0], [screenRowRange[1], MAX_LINE_LENGTH]]
    @marker = editor.markScreenRange range,
      invalidate: 'never'
      class: 'ecb-mark'
      persistent: false
    @editorView = createEditorView @editor
    blockCursorIf @editor, 'moveCursorUp', (currentRow) =>
      currentRow - 1 < @marker.getTailScreenPosition().row
    blockCursorIf @editor, 'moveCursorDown', (currentRow) =>
      currentRow + 1 > @marker.getHeadScreenPosition().row
    @setTitle()
    @editorEl.append @editorView
    @handleEvents()

  handleEvents: ->
    @subscribe @editor, 'modified-status-changed', => @setTitle()
    @subscribe @editor, 'screen-lines-changed', => @setBounds()
    @subscribe @editorView, 'editor:attached', => @setBounds()
    @subscribe @editorView.verticalScrollbar, 'scroll', => @snapToPartial()
    @subscribe @goEl, 'click', =>
      atom.workspaceView.open @editor.buffer.getUri(),
        split: 'left'
        searchAllPanes: true
      .done (editor) =>
        bufferPos = @marker.getTailBufferPosition()
        editor.scrollToBufferPosition bufferPos
        editor.setCursorBufferPosition bufferPos

  setTitle: ->
    title = getTitleFromUri @editor.buffer.getUri()
    title += ' ~' if @editor.isModified()
    @titleEl.html title

  setBounds: ->
    @editorView.css
      height: markerHeightPx @marker, @editorView
    @editorView.scrollTop markerTopPx @marker, @editorView

  snapToPartial: ->
    clearTimeout @snapTimeout if @snapTimeout
    @snapTimeout = setTimeout (=> @setBounds()), SNAP_TIMEOUT

  focus: ->
    @editorView.focus()
    @trigger 'partial-editor-focused', [this]
