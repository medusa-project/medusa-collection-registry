Then(/^there should be an exported directory with paths:$/) do |table|
  root_dir = Dir[File.join(CfsDirectory.export_root, 'manager','*')].detect {|entry| File.directory?(entry)}
  table.headers.each do |path|
    expect(File.exists?(File.join(root_dir, path))).to be_true
  end
end