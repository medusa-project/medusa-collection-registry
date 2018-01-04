class ProjectDirectoryRow extends React.Component {
    constructor(props) {
        super(props);
    }

    handleUse(e) {
        e.preventDefault();
        return this.props.onUse(this.props.name);
    }

    handleDown(e) {
        e.preventDefault();
        return this.props.onDown(this.props.name);
    }

    render() {
        return (
          <li key={this.props.name}>
              <p className="btn btn-xs btn-default" onClick={this.handleUse}>
                  Use
              </p>
              <a className='btn btn-xs btn-default' onClick={this.handleDown}>
                  Down
              </a>
              {this.props.name}
          </li>
        );
    }
}
// @ProjectDirectoryRow = React.createClass
//   handleUse: (e) ->
//     e.preventDefault()
//     @props.onUse(@props.name)
//   handleDown: (e) ->
//     e.preventDefault()
//     @props.onDown(@props.name)
//   render: ->
//     React.DOM.li key: @props.name,
//       React.DOM.p
//         className: 'btn btn-xs btn-default'
//         onClick: @handleUse
//         'Use'
//       React.DOM.a
//         className: 'btn btn-xs btn-default'
//         onClick: @handleDown
//         'Down'
//       @props.name