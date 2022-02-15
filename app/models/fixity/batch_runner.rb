# deprecated -- not doing fixity this way anymore
=begin
require 'fileutils'

class Fixity::BatchRunner

  attr_accessor :batch_size, :sub_batch_limit, :fixity_stop_file

  def initialize(batch_size = nil, sub_batch_limit = nil, fixity_stop_file = nil)
    self.batch_size = batch_size || Settings.fixity_runner.default_batch_size
    self.sub_batch_limit = sub_batch_limit || Settings.fixity_runner.sub_batch_limit
    self.fixity_stop_file = fixity_stop_file || Settings.fixity_runner.fixity_stop_file
  end

  def run
    circular_loading_kludge
    errors = Concurrent::Hash.new
    mutex = Mutex.new
    bar = ProgressBar.new(batch_size)
    sub_batch_size = [batch_size, sub_batch_limit].min
    self.batch_size -= sub_batch_size
    while sub_batch_size > 0
      begin
        Parallel.each(fixity_files(sub_batch_size).to_a.sort_by!(&:size).reverse!,
                      in_threads: Settings.fixity_runner.thread_count) do |cfs_file|
          unless File.exist?(fixity_stop_file)
            begin
              cfs_file.update_fixity_status_with_event
              maybe_add_error(cfs_file, errors)
              mutex.synchronize do
                bar.increment!
              end
            rescue RSolr::Error::Http => e
              errors[cfs_file] = e.to_s
              FileUtils.touch(fixity_stop_file)
            rescue Exception => e
              errors[cfs_file] = e.to_s
              if errors.length > 25
                FileUtils.touch(fixity_stop_file)
              end
            end
          end
        end
        break if File.exist?(fixity_stop_file)
        sub_batch_size = [batch_size, sub_batch_limit].min
        self.batch_size -= sub_batch_size
      ensure
        Sunspot.commit
      end
    end
    if errors.present?
      GenericErrorMailer.error(error_string(errors), subject: 'Fixity batch error').deliver_now
    end
  end

  def fixity_files(batch_size)
    if CfsFile.where(fixity_check_status: nil).where('size is not null').first
      CfsFile.where(fixity_check_status: nil).where('size is not null').limit(batch_size)
    else
      timeout = (Settings.medusa.fixity_interval || 90).days
      CfsFile.where('fixity_check_time < ?', Time.now - timeout).order('fixity_check_time asc').limit(batch_size)
    end
  end

  def error_string(errors)
    error_string = StringIO.new
    error_string.puts "Fixity errors"
    errors.each do |k, v|
      error_string.puts "#{k.id}: #{v}"
    end
    error_string.string
  end

  def maybe_add_error(cfs_file, errors)
    unless cfs_file.fixity_check_status == 'ok'
      puts "#{cfs_file.id}: #{cfs_file.fixity_check_status}"
      case cfs_file.fixity_check_status
      when 'bad'
        errors[cfs_file] = 'Bad fixity'
      when 'nf'
        errors[cfs_file] = 'Not found'
      else
        raise RuntimeError, 'Unrecognized fixity check status'
      end
    end
  end

  #Somehow the introduction of Parallel seems to have caused a circular loading problem.
  # Why, I do not understand, since the entire environment should be loaded before the parallel
  # section is reached (when we run this via a rake task we require the environment),
  # and no where else do I ever see a problem, even with other uses of
  # Parallel. Since using Parallel here is quite useful (~3-4x speedup), kludge around it by
  # forcing them to load here before getting to the Parallel part.
  # UPDATE: Doing an explicit eager load seems to work, at least so far. I don't know what could be
  # going on here with Parallel that would require this, though. Others have had the problem, e.g.
  # https://stackoverflow.com/questions/36382752/handling-circular-dependency-in-rails-while-using-threads,
  # and this solution seems to work here.
  def circular_loading_kludge
    Rails.application.eager_load!
    # CfsFile
    # CfsDirectory
    # FileGroup
    # BitLevelFileGroup
    # Collection
    # FileExtension
    # FixityCheckResult
  end

end
=end
