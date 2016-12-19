@ProjectDirectoryRow = React.createClass
  handleUse: (e) ->
    e.preventDefault()
    @props.onUse(@props.name)
  render: ->
    React.DOM.li key: @props.name,
      React.DOM.a
        className: 'btn btn-xs btn-default'
        onClick: @handleUse
        'Use'
      React.DOM.a
        className: 'btn btn-xs btn-default'
        'Down'
      @props.name