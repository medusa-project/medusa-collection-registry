@ProjectDirectoryRow = React.createClass
  handleUse: (e) ->
    e.preventDefault()
    @props.onUse(@props.name)
  handleDown: (e) ->
    e.preventDefault()
    @props.onDown(@props.name)
  render: ->
    React.DOM.li key: @props.name,
      React.DOM.p
        className: 'btn btn-xs btn-default'
        onClick: @handleUse
        'Use'
      React.DOM.a
        className: 'btn btn-xs btn-default'
        onClick: @handleDown
        'Down'
      @props.name