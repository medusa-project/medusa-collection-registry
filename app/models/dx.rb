require 'singleton'
require 'fileutils'
require 'fits'

class Dx < Object
  include Singleton
  attr_accessor :client, :domain, :entry_host, :bucket, :use_test_headers, :object_auth_realm,
                :user, :password

  def initialize(args = {})
    self.configure
  end

  def with_retries(opts, success_message, error_message, retry_function, *retry_arguments)
    yield
    Rails.logger.info success_message
  rescue Exception => e
    Rails.logger.error "#{error_message}: #{e}"
    if opts[:retries] == 0
      Rails.logger.error 'Aborting.'
      raise e
    else
      Rails.logger.error "Retrying. #{opts[:retries]} remaining."
      sleep 1
      self.send(retry_function, *retry_arguments)
    end
  end

  def ingest_file(file_path, bit_file, opts = {})
    opts[:retries] ||= 5
    with_retries(opts, "DX Ingested #{bit_file.name}", "Error DX Ingesting #{bit_file.name}", :ingest_file, file_path, bit_file, opts.merge(:retries => opts[:retries] - 1)) do
      content = File.open(file_path, 'rb') { |f| f.read }
      self.client.post(file_url(bit_file), content, ingest_headers(bit_file, file_path, opts))
    end
  end

  def delete_file(bit_file, retries = 5)
    with_retries({:retries => retries}, "DX Deleted #{bit_file.name}:#{bit_file.dx_name}.", "Error DX Deleting #{bit_file.name}:#{bit_file.dx_name}", :delete_file, bit_file, retries - 1) do
      begin
        self.client.delete(file_url(bit_file), {}, delete_headers(bit_file))
      rescue Mechanize::ResponseCodeError => e
        if e.response_code.to_i == 403 or e.response_code.to_i == 404
          Rails.logger.info "#{bit_file.name} already deleted from DX."
        else
          raise e
        end
      end
    end
  end

  def export_file(bit_file, target_directory, retries = 5)
    filename = File.join(target_directory, bit_file.name)
    with_retries({:retries => retries}, "DX exported file: #{bit_file.name}", "Error DX exporting #{bit_file.name}", :export_file, bit_file, target_directory, retries - 1) do
      response = self.client.download(file_url(bit_file), filename, [], nil, export_headers(bit_file))
      begin
        atime = Time.parse(response.header['x-bit-meta-atime'])
        mtime = Time.parse(response.header['x-bit-meta-mtime'])
        File.utime(atime, mtime, bit_file.name)
      rescue Exception => e
        Rails.logger.error "Problem resetting atime and mtime for #{filename}. Skipping"
      end
    end
  end

  #this variation is useful for getting one specific file
  def export_file_2(bit_file, io_or_file_name)
    self.client.download(file_url(bit_file), io_or_file_name, [], nil, export_headers(bit_file))
  end

  def file_url(bit_file)
    "http://#{self.entry_host}/#{self.bucket}/#{bit_file.dx_name}"
  end

  def file_url_with_domain(bit_file)
    if self.domain
      "#{file_url(bit_file)}?domain=#{self.domain}"
    else
      file_url(bit_file)
    end
  end

  def get_fits_for(bit_file)
    Fits::Service.instance.get_fits_for(file_url_with_domain(bit_file), user, password)
  end

  protected

  def configure
    config = YAML.load_file(File.join(Rails.root, 'config', 'dx.yml'))[Rails.env]
    self.user = config['user']
    self.password = config['password']
    self.client = Mechanize.new.tap do |agent|
      config['hosts'].each do |host|
        agent.add_auth("http://#{host}", user, password)
      end
      logfile = File.join(Rails.root, 'log', 'mech.log')
      FileUtils.touch(logfile)
      agent.log = Logger.new(logfile)
      agent.redirects_preserve_verb = true
      agent.max_history = 1
    end
    self.domain = config['domain']
    self.entry_host = config['entry_host']
    self.bucket = config['bucket']
    self.use_test_headers = config['use_test_headers'] || false
    self.object_auth_realm = config['object_auth_realm']
  end

  def ingest_headers(bit_file, file_path, opts)
    Hash.new.tap do |headers|
      add_domain_header(headers)
      headers['Content-Type'] = bit_file.content_type || 'application/octet-stream'
      headers['Content-MD5'] = bit_file.md5sum if bit_file.md5sum
      headers['x-bit-meta-atime'] = File.atime(file_path).to_s
      headers['x-bit-meta-ctime'] = File.ctime(file_path).to_s
      headers['x-bit-meta-mtime'] = File.mtime(file_path).to_s
      headers['x-bit-meta-path'] = File.join(opts[:path], bit_file.name)
      headers['x-bit-meta-collection-id'] = bit_file.directory.collection_id
      headers['Castor-Authorization'] = self.object_auth_realm if self.object_auth_realm
      add_lifepoint_header(headers)
    end
  end

  def delete_headers(bit_file)
    Hash.new.tap do |headers|
      add_domain_header(headers)
    end
  end

  def export_headers(bit_file)
    Hash.new.tap do |headers|
      add_domain_header(headers)
    end
  end

  def add_domain_header(headers)
    headers['Host'] = self.domain if self.domain
  end

  def add_lifepoint_header(headers)
    if self.use_test_headers
      #set lifepoint to assure that content gets deleted after 2 weeks even if we don't clean it up manually
      headers['Lifepoint'] = ["[#{(Time.now + 2.weeks).httpdate}] reps=2, deletable=yes",
                              '[] delete']
    else
      headers['Lifepoint'] = '[] reps=3, deletable=yes'
    end
  end

end