{$, ScrollView} = require 'atom'
PartialEditorView = require './partial-editor-view'
_ = require 'lodash'

findActiveEditorEl = (root) ->
  el = root.find('.editor.is-focused')
  return el if el.length > 0

findActiveEditor = (root) ->
  findActiveEditorEl(root)?.view().editor;

findActivePartialView = (root) ->
  findActiveEditorEl(root)?.parents('.partial-editor')?.view()

getPartialViews = (root) ->
  _.map root.find('.partial-editor'), (el) -> $(el).view()

# Finds next view to focus on - defaults to next in dom tree if it exists,
# else previous
nextToFocus = (view) ->
  next = view.next()
  if next.length > 0
    next.view()
  else
    view.prev().view()

move = (view, getPlaceholder, attach) ->
  active = findActivePartialView(view)
  placeHolder = getPlaceholder(active)
  if placeHolder.length > 0
    active.detach()
    attach(placeHolder, active)
    active.focus()

module.exports =
class EditCodeBlocksView extends ScrollView

  @content: ->
    @div class: 'edit-code-blocks-view', tabindex: -1

  constructor: ({@host, @pathname}) ->
    super
    @command 'core:close', (e) => @closePartial(e)
    @command 'edit-code-blocks:move-partial-down', => @moveActiveDown()
    @command 'edit-code-blocks:move-partial-up', => @moveActiveUp()

  getTitle: ->
    @getUri()

  getUri: ->
    "ecb://ecb"

  save: ->
    findActiveEditor(this)?.save()

  moveActiveDown: ->
    move this,
      (active) -> active.next(),
      (placeHolder, active) -> placeHolder.after(active)

  moveActiveUp: ->
    move this,
      (active) -> active.prev(),
      (placeHolder, active) -> placeHolder.before(active)

  addPartial: (editor) ->
    selection = editor.getSelection()
    range = selection.getScreenRange()
    rowRange = [range.start.row, range.end.row]
    selection.clear()

    partialEditorView = new PartialEditorView editor.copy(), rowRange
    @append partialEditorView
    partialEditorView.focus()

  closePartial: (e) ->
    if getPartialViews(this).length > 1
      e.stopPropagation()
      active = findActivePartialView(this)
      next = nextToFocus(active)
      active.detach()
      next.focus()
    else
      # If only one partial editor, defer to normal pane close
      e.abortKeyBinding()
