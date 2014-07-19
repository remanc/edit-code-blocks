{ScrollView} = require 'atom'
PartialEditorView = require './partial-editor-view'

module.exports =
class EditCodeBlocksView extends ScrollView

  @content: ->
    @div class: 'edit-code-blocks-view', tabindex: -1

  constructor: ({@host, @pathname}) ->
    super

  getTitle: ->
    @getUri()

  getUri: ->
    "ecb://ecb"

  save: ->
    activeEditorEl = @find('.editor.is-focused')
    return unless activeEditorEl.length > 0
    activeEditor = activeEditorEl.view().editor
    activeEditor.save()

  addPartial: (editor) ->
    selection = editor.getSelection()
    range = selection.getScreenRange()
    rowRange = [range.start.row, range.end.row]
    selection.clear()

    partialEditorView = new PartialEditorView editor.copy(), rowRange
    @append partialEditorView
    partialEditorView.focus()
