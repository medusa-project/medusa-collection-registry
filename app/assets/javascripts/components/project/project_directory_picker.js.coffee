@ProjectDirectoryPicker = React.createClass
  getInitialState: ->
    current: @props.data.current
    children: @props.data.children
    parent: @props.data.parent
  setDirectory: (e) ->
    e.preventDefault()
    path = @state.current
    if e.target.dataset.name
      path = path + e.target.dataset.name
    $('#project_ingest_folder').val(path)
    $('#directory-picker').modal('hide')
  render: ->
    React.DOM.div
      className: 'project-directory-picker'
      React.DOM.div
        className: null
        React.DOM.a
          className: 'btn btn-xs btn-default'
          onClick: @setDirectory
          'Use'
        React.DOM.a
          className: 'btn btn-xs btn-default'
          'Up'
        @state.current
      React.DOM.ul
        for child in @state.children
          React.createElement ProjectDirectoryRow, key: child, name: child, handleUse: @setDirectory
          