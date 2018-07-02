{CompositeDisposable} = require 'atom'

module.exports =
  configDefaults:
    patterns: ['\^\\s+\\#']

  config:
    patterns:
      type: 'array'
      default: ['\^\\s+\\#']
      description: 'Comma separated list of regex patterns to hide'
      items:
        type: 'string'

  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'hide-lines:hide': => @hide()
      'hide-lines:show': => @show()

  deactivate: ->
    @subscriptions.dispose()

  hide: ->
    rowsToHide = []
    patterns   = atom.config.get('hide-lines.patterns')
    editor     = @editor()

    for pattern in patterns
      editor.scan new RegExp(pattern, 'g'), (m) ->
        row = m.range.end.row

        if rowsToHide.indexOf(row) == -1
          rowsToHide.push(row)

    sets = []

    for row in rowsToHide.sort()
      lastSet = sets[sets.length - 1]
      if !lastSet || lastSet[1] + 1 != row
        sets.push([row, row])
      else
        lastSet[1] = row

    for set in sets
      editor.foldBufferRange([[set[0], 0], [set[1], 999]])

  show: ->
    @editor().unfoldAll()

  editor: ->
    atom.workspace.getActiveTextEditor()
