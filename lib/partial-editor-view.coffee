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
    @div class: "partial-editor tool-panel panel-bottom", =>
      @div class: "inset-panel", =>
        @div class: "panel-heading", =>
          @div class: 'btn-toolbar pull-right', =>
            @button class: 'btn', outlet: 'goEl', 'Go to file'
          @span outlet: 'titleEl'
        @div class: "panel-body padded", outlet: 'editorEl'

  initialize: (@editor, screenRowRange) ->
    range = [[screenRowRange[0], 0], [screenRowRange[1], MAX_LINE_LENGTH]]
    @marker = editor.markScreenRange range,
      invalidate: 'never'
      class: 'scratch-mark'
      persistent: false
    @editorView = createEditorView @editor
    blockCursorIf @editor, 'moveCursorUp', (currentRow) =>
      currentRow - 1 < @marker.getTailScreenPosition().row
    blockCursorIf @editor, 'moveCursorDown', (currentRow) =>
      currentRow + 1 > @marker.getHeadScreenPosition().row
    @titleEl.append getTitleFromUri @editor.buffer.getUri()
    @editorEl.append @editorView
    @handleEvents()

  handleEvents: ->
    @subscribe @editor, 'screen-lines-changed', => @setPartial()
    @subscribe @editorView, 'editor:attached', => @setPartial()
    @subscribe @editorView.verticalScrollbar, 'scroll', => @snapToPartial()
    @subscribe @goEl, 'click', =>
      atom.workspaceView.open @editor.buffer.getUri(),
        split: 'left'
        searchAllPanes: true
      .done (editor) =>
        bufferPos = @marker.getTailBufferPosition()
        editor.scrollToBufferPosition bufferPos
        editor.setCursorBufferPosition bufferPos

  setPartial: ->
    @editorView.scrollTop markerTopPx @marker, @editorView
    @editorView.css
      height: markerHeightPx @marker, @editorView

  snapToPartial: ->
    clearTimeout @snapTimeout if @snapTimeout
    @snapTimeout = setTimeout (=> @setPartial()), SNAP_TIMEOUT

  focus: -> @editorView.focus()
