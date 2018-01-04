class ProjectDirectoryPicker extends React.Component {
    constructor(props) {
        super(props);

        // This binding is necessary to make `this` work in the callback
        //this.handleClick = this.handleClick.bind(this);
    }

    getInitialState() {
        return {
            current: this.props.data.current,
            children: this.props.data.children,
            parent: this.props.data.parent
        };
    }

    getDirectoryInfo(path) {
        return $.getJSON('/projects/ingest_path_info', {path: path}, (data) => this.replaceState(data));
    }

    getChildDirectoryInfo(path) {
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

    render() {
        return
        (
            <div className='project-directory-picker'>
                <div>
                    <a className='btn btn-xs btn-default' onClick={this.handleUse}>
                        Use
                    </a>
                    {(this.state.current == '/') ||
                    <a className='btn btn-xs btn-default' onClick={this.handleUp}>
                        Up
                    </a>
                    }
                    {this.state.current}
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