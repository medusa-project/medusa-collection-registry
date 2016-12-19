@ProjectDirectoryPicker = React.createClass
  getInitialState: ->
    current: @props.data.current
    children: @props.data.children
    parent: @props.data.parent
  setDirectory: (child_path) ->
    path = @state.current
    if child_path
      path = path + child_path
    $('#project_ingest_folder').val(path)
    $('#directory-picker').modal('hide')
  handleUse: (e) ->
    e.preventDefault()
    @setDirectory(null)
  render: ->
    React.DOM.div
      className: 'project-directory-picker'
      React.DOM.div
        className: null
        React.DOM.a
          className: 'btn btn-xs btn-default'
          onClick: @handleUse
          'Use'
        unless @state.current == '/'
          React.DOM.a
            className: 'btn btn-xs btn-default'
            'Up'
        @state.current
      React.DOM.ul
        for child in @state.children
          React.createElement ProjectDirectoryRow, key: child, name: child, onUse: @setDirectory
          