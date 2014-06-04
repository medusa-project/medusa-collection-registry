#must pass in file; may pass in show_path
show_path ||= false
json.(file, :id, :name, :md5_sum, :content_type)
json.size (file.size ? file.size.to_i : nil)
json.mtime (file.mtime ? file.mtime.iso8601 : nil)
json.path(cfs_file_path(file, format: :json)) if show_path
