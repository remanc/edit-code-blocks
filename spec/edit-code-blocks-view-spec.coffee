EditCodeBlocksView = require '../lib/edit-code-blocks-view'

describe 'EditCodeBlocksView', ->

  beforeEach ->
    @view = new EditCodeBlocksView protocol: 'ecb:', host: '1'
    @view.attachToDom()

  describe 'getUri', ->

    it 'returns the right uri', ->
      v1 = new EditCodeBlocksView protocol: 'foo:', host: '1'
      expect(v1.getUri()).toBe('foo://1')
      v2 = new EditCodeBlocksView protocol: 'bar:', host: '2'
      expect(v2.getUri()).toBe('bar://2')

  xdescribe 'addPartial', ->

    it 'creates a new PartialEditorView with the right selection and appends'

    it 'clears the previous selection on the editor'

    it 'uses a copy of the editor'

    it 'focuses on the new partialEditor'

  xdescribe 'events', ->

    describe 'when core:close', ->

      describe 'and there are multiple partials', ->

        it 'detaches the active partial'

        it 'focuses on the next partial if it exists'

        it 'focuses on the previous partial if next partial does not exist'

      describe 'and there is only one partial', ->

        it 'delegates to the next handler for core:close'

    describe 'when edit-code-blocks:jump-partial-down', ->

      it 'focuses on next partial if it exists'

      it 'remains on current partial if no next'

    describe 'when edit-code-blocks:jump-partial-up', ->

      it 'focuses on previous partial if it exists'

      it 'remains on current partial if no previous'

    describe 'when edit-code-blocks:move-partial-down', ->

      it 'does not move if its the last partial'

      it 'moves after the next partial if its not the last'

      it 'keeps focus after moving'

    describe 'when edit-code-blocks:move-partial-up', ->

      it 'does not move if its the first partial'

      it 'moves before the previous partial if its not the first'

      it 'keeps focus after moving'

  xdescribe 'save', ->

    it 'saves the active partial when a save command is triggered'

  xdescribe 'focus', ->

    it 'focuses on last focused partial'

    it 'focuses on first partial if never focused before'
