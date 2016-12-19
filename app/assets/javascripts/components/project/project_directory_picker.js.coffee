@ProjectDirectoryPicker = React.createClass
  getInitialState: ->
    current: @props.data.current
    children: @props.data.children
    parent: @props.data.parent
  getDirectoryInfo: (path) ->
    $.get '/projects/ingest_path_info', {path: path},
      (data) => @replaceState data,
      'JSON'
  getChildDirectoryInfo: (child_path) ->
    @getDirectoryInfo(@state.current + child_path)
  setDirectory: (child_path) ->
    path = @state.current
    if child_path
      path = path + child_path
    $('#project_ingest_folder').val(path)
    $('#directory-picker').modal('hide')
  handleUse: (e) ->
    e.preventDefault()
    @setDirectory(null)
  handleUp: (e) ->
    e.preventDefault()
    @getDirectoryInfo(@state.parent)
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
            onClick: @handleUp
            'Up'
        @state.current
      React.DOM.ul
        for child in @state.children
          React.createElement ProjectDirectoryRow, key: child, name: child, onUse: @setDirectory, onDown: @getChildDirectoryInfo
          