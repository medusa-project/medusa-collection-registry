@IngestDirectoryPicker = React.createClass
  getInitialState: ->
    current: @props.data.current
    children: @props.data.children
    parent: @props.data.parent
  render: ->
    React.DOM.div
      className: 'ingest-directory-picker'
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
          React.DOM.li key: child,
            React.DOM.a
              className: 'btn btn-xs btn-default'
              'Use'
            React.DOM.a
              className: 'btn btn-xs btn-default'
              'Down'
            child