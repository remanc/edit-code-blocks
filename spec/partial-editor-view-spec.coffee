PartialEditorView = require '../lib/partial-editor-view'

BOUND_TOP = 23
BOUND_BOTTOM = 26

getEditorView = (view) ->
  view.find('.item-views .editor').view()

getMarkerText = (buffer) ->
  marker = buffer.findMarkers(class: 'ecb-mark')[0]
  buffer.getTextInRange marker.getRange()

getCursorRow = (editor) ->
  editor.getCursor().getScreenRow()

expectTitle = (view, title) ->
  expect(view.find('.pev-title').text()).toBe title

expectBounded = (editorView, diff) ->
  numLines = BOUND_BOTTOM - BOUND_TOP + 1 + diff
  lineHeight = editorView.lineHeight
  expect(editorView.height()).toBeCloseTo numLines * lineHeight
  expect(editorView.scrollTop()).toBe BOUND_TOP * lineHeight

scroll = (editorView, pos) ->
  editorView.verticalScrollbar.scrollTop pos
  editorView.verticalScrollbar.trigger 'scroll'

describe 'PartialEditorView', ->

  beforeEach ->
    waitsForPromise =>
      atom.workspace.open('sample.txt').then (origEditor) =>
        @editor = origEditor.copy()
    runs =>
      @partial = new PartialEditorView @editor, [BOUND_TOP, BOUND_BOTTOM]
      @editorView = getEditorView @partial
      @buffer = @editor.buffer
      @partial.attachToDom()

  describe 'initialize', ->

    it 'creates the correct editor mark', ->
      expect(getMarkerText(@buffer)).toBe 'Line 24\nLine 25\nLine 26\nLine 27'

    it 'sets the correct title', ->
      expectTitle @partial, 'sample.txt'

    describe 'editorView', ->

      it 'creates an editorView with editor, appends it', ->
        expect(@editorView.editor).toBe @editor

      it 'overrides editorView vScrollMargin to 0', ->
        expect(@editorView.vScrollMargin).toBe 0

    describe 'editor', ->

      it 'prevents cursor from moving up out of bounds', ->
        @editor.setCursorScreenPosition([BOUND_TOP + 1, 0])
        @editor.moveCursorUp()
        expect(getCursorRow(@editor)).toBe(BOUND_TOP)
        @editor.moveCursorUp()
        expect(getCursorRow(@editor)).toBe(BOUND_TOP)

      it 'prevents cursor from moving down out of bounds', ->
        @editor.setCursorScreenPosition([BOUND_BOTTOM - 1, 0])
        @editor.moveCursorDown()
        expect(getCursorRow(@editor)).toBe(BOUND_BOTTOM)
        @editor.moveCursorDown()
        expect(getCursorRow(@editor)).toBe(BOUND_BOTTOM)

  describe 'events', ->

    describe 'when editor changes', ->

      it 'adds ~ to title in unsaved state', ->
        @buffer.append 'some text'
        advanceClock 1000
        expectTitle @partial, 'sample.txt ~'

      it 'removes ~ from title in saved state', ->
        @buffer.insert [0,0], 'a'
        advanceClock 1000
        @buffer.delete [[0,0], [0,1]]
        advanceClock 1000
        expectTitle @partial, 'sample.txt'

      it 'resets bounds when dom is attached', ->
        expectBounded @editorView, 0

      it 'resets bounds when screen lines are changed', ->
        @buffer.insert [24, 0], 'Another line\n'
        expectBounded @editorView, 1

    describe 'when scrolling', ->

      it 'resets scrollTop after 1 second', ->
        scroll @editorView, 0
        advanceClock 500
        expect(@editorView.scrollTop()).toBe 0
        advanceClock 700
        expectBounded @editorView, 0

      it 'sets 1 second timeout only after finished scrolling', ->
        scroll @editorView, 0
        advanceClock 500
        scroll @editorView, 10
        advanceClock 700
        expect(@editorView.scrollTop()).toBe 10
        advanceClock 400
        expectBounded @editorView, 0

    describe 'when go link is clicked', ->

      xit 'opens file in new tab'

      xit 'scrolls to correct buffer position'

  describe 'focus', ->

    it 'delegates focus to its editorView', ->
      @partial.focus()
      expect(@editorView.isFocused).toBe true

    it 'triggers partial-editor-focused event', ->
      spyOn @partial, 'trigger'
      @partial.focus()
      calls = @partial.trigger.calls
      expect(calls.length).toBe 1
      expect(calls[0].args[0]).toBe 'partial-editor-focused'
      expect(calls[0].args[1][0]).toBe @partial
