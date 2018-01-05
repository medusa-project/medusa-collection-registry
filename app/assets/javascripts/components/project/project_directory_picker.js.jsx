class ProjectDirectoryPicker extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      current: props.data.current,
      children: props.data.children,
      parent: props.data.parent
    };

    this.handleUse = this.handleUse.bind(this);
    this.handleUp = this.handleUp.bind(this);
    this.setDirectory = this.setDirectory.bind(this);
    this.getChildDirectoryInfo = this.getChildDirectoryInfo.bind(this);
  }

  getDirectoryInfo(path) {
    return $.getJSON('/projects/ingest_path_info', {path: path}, (data) => this.setState(data));
  }

  getChildDirectoryInfo(child_path) {
    return this.getDirectoryInfo(this.state.current + child_path);
  }

  setDirectory(child_path) {
    var path = this.state.current;
    if (child_path) {
      path = path + child_path;
    }
    $('#project_ingest_folder').val(path);
    $('#directory-picker').modal('hide');
  }

  handleUse(e) {
    e.preventDefault();
    this.setDirectory(null);
  }

  handleUp(e) {
    e.preventDefault();
    this.getDirectoryInfo(this.state.parent);
  }

  currentState() {
    return this.state.current;
  }

  render() {
    return (
      <div className='project-directory-picker'>
        <div>
          <a className='btn btn-xs btn-default' onClick={this.handleUse}>
            Use
          </a>
          {(this.currentState() == '/') ||
          <a className='btn btn-xs btn-default' onClick={this.handleUp}>
            Up
          </a>
          }
          {this.currentState()}
        </div>
        <ul>
          {this.state.children.map((child) =>
            <ProjectDirectoryRow key={child} name={child}
                                 onUse={this.setDirectory} onDown={this.getChildDirectoryInfo}/>)
          }
        </ul>
      </div>
    );
  }
}

// @ProjectDirectoryPicker = React.createClass
//   getInitialState: ->
//     current: @props.data.current
//     children: @props.data.children
//     parent: @props.data.parent
//   getDirectoryInfo: (path) ->
//     $.get '/projects/ingest_path_info', {path: path},
//       (data) => @replaceState data,
//       'JSON'
//   getChildDirectoryInfo: (child_path) ->
//     @getDirectoryInfo(@state.current + child_path)
//   setDirectory: (child_path) ->
//     path = @state.current
//     if child_path
//       path = path + child_path
//     $('#project_ingest_folder').val(path)
//     $('#directory-picker').modal('hide')
//   handleUse: (e) ->
//     e.preventDefault()
//     @setDirectory(null)
//   handleUp: (e) ->
//     e.preventDefault()
//     @getDirectoryInfo(@state.parent)
//   render: ->
//     React.DOM.div
//       className: 'project-directory-picker'
//       React.DOM.div
//         className: null
//         React.DOM.a
//           className: 'btn btn-xs btn-default'
//           onClick: @handleUse
//           'Use'
//         unless @state.current == '/'
//           React.DOM.a
//             className: 'btn btn-xs btn-default'
//             onClick: @handleUp
//             'Up'
//         @state.current
//       React.DOM.ul
//         className: null,
//         for child in @state.children
//           React.createElement ProjectDirectoryRow, key: child, name: child, onUse: @setDirectory, onDown: @getChildDirectoryInfo
//