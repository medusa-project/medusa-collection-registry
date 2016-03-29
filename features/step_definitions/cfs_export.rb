Then(/^there should be an exported directory with paths:$/) do |table|
  root_dir = Dir[File.join(CfsDirectory.export_root, 'manager','*')].detect {|entry| File.directory?(entry)}
  table.headers.each do |path|
    expect(File.exists?(File.join(root_dir, path))).to be_truthy
  end
end

And(/^there should be a (.*) download request for the export of the cfs directory for the file group titled '(.*)' for the path '(.*)'$/) do |type, title, path|
  cfs_root = FileGroup.find_by(title: title).cfs_directory
  cfs_directory = cfs_root.find_directory_at_relative_path(path)
  request = Downloader::Request.find_by(cfs_directory: cfs_directory)
  expect(request).to be_truthy
  AmqpConnector.connector(:downloader).with_parsed_message(Application.downloader_config.outgoing_queue) do |message|
    expect(message['action']).to eq('export')
    expect(message['client_id']).to eq(request.id.to_s)
    expect(message['return_queue']).to eq(Application.downloader_config.incoming_queue.to_s)
    expect(message['root']).to eq(Application.downloader_config.root)
    expect(message['zip_name']).to eq(File.basename(cfs_directory.path))
    targets = message['targets']
    expect(targets.length).to eq(1)
    target = targets.first
    recursive = (type == 'recursive')
    expect(target['type']).to eq('directory')
    expect(target['recursive']).to eq(recursive)
    expect(target['path']).to eq(cfs_directory.relative_path)
    expect(target['zip_path']).to eq('')
  end
end

Then(/^the downloader request with id '(.*)' should have status '(.*)'$/) do |id, status|
  expect(Downloader::Request.find_by(downloader_id: id).status).to eq(status)
end

Given(/^there is a downloader request for the export of the cfs directory for the file group titled '(.*)' for the path '(.*)' with fields:$/) do |title, path, table|
  cfs_root = FileGroup.find_by(title: title).cfs_directory
  cfs_directory = cfs_root.find_directory_at_relative_path(path)
  FactoryGirl.create(:downloader_request, table.hashes.first.merge(cfs_directory_id: cfs_directory.id))
end

When(/^a downloader request completed message is received with id '(.*)'$/) do |id|
  request = Downloader::Request.first
  Downloader::Request.handle_response(request_completed_message(request))
end

When(/^a downloader error message is received with id '(.*)'$/) do |id|
  request = Downloader::Request.first
  Downloader::Request.handle_response(error_message(request))
end

When(/^a downloader request received message is received with id '(.*)'$/) do |id|
  request = Downloader::Request.first
  Downloader::Request.handle_response(request_received_message(request, id))
end

def request_received_message(request, downloader_id)
  Hash.new.tap do |h|
    h[:client_id] = request.id
    h[:action] = 'request_received'
    h[:id] = downloader_id
    h[:status] = 'ok'
  end.to_json
end

def error_message(request)
  Hash.new.tap do |h|
    h[:id] = request.downloader_id
    h[:action] = 'error'
    h[:error] = 'Something wrong'
  end.to_json
end

def request_completed_message(request)
  Hash.new.tap do |h|
    h[:id] = request.downloader_id
    h[:action] = 'request_completed'
    h[:approximate_size] = 987654
    h[:download_url] = "http://download.example.com/download_id/get"
  end.to_json
end