@ProjectDirectoryPicker = React.createClass
  getInitialState: ->
    current: @props.data.current
    children: @props.data.children
    parent: @props.data.parent
  render: ->
    React.DOM.div
      className: 'project-directory-picker'
      React.DOM.div
        className: null
        React.DOM.a
          className: 'btn btn-xs btn-default'
          'Use'
        React.DOM.a
          className: 'btn btn-xs btn-default'
          'Up'
        @state.current
      React.DOM.ul
        for child in @state.children
          React.createElement ProjectDirectoryRow, key: child, name: child
          