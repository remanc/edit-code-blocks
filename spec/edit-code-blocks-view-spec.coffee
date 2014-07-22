EditCodeBlocksView = require '../lib/edit-code-blocks-view'

describe 'EditCodeBlocksView', ->

  describe 'getUri', ->

    it 'returns the right uri'

  describe 'events', ->

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

  describe 'focus', ->

    it 'focuses on last focused partial'

    it 'focuses on first partial if never focused before'
