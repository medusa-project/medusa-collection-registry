@ProjectDirectoryRow = React.createClass
  render: ->
    React.DOM.li key: @props.name,
      React.DOM.a
        className: 'btn btn-xs btn-default'
        onClick: @props.handleUse
        'data-name': @props.name
        'Use'
      React.DOM.a
        className: 'btn btn-xs btn-default'
        'Down'
      @props.name