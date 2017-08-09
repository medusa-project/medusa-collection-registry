#note that if the batch size is too large the queries may become problematic. 1000 seems to work.
class Job::SunspotReindex < Job::Base

  def self.create_for(class_or_class_name, start_id: 0, end_id: 0, batch_size: 1000)
    Delayed::Job.enqueue(self.create!(class_name: class_or_class_name.to_s, start_id: start_id, end_id: end_id, batch_size: batch_size),
                         priority: 100)
  end

  def perform
    models = klass.where('id >= ?', start_id).order('id asc').limit(batch_size)
    Sunspot.index models
    remove_orphans(models)
    if models.last.id < end_id and start_id < end_id
      self.class.create_for(class_name, start_id: [models.last.id + 1, start_id + batch_size].max, end_id: end_id, batch_size: batch_size)
    end
    Sunspot.commit
  end

  #This is a little convoluted, but should be safe and also work where
  #model_id hasn't been indexed yet (when results out of range might be returned)
  #or there are other problems
  def remove_orphans(models)
    present_ids = models.collect(&:id).to_set
    last_id = models.last.id
    search = klass.search do
      with(:model_id).greater_than_or_equal_to(start_id)
      with(:model_id).less_than_or_equal_to(last_id)
      paginate page: 1, per_page: (last_id - start_id + 1)
    end
    potential_bad_ids = search.hits.collect {|hit| hit.primary_key.to_i}
    bad_ids = potential_bad_ids.to_set - klass.where(id: potential_bad_ids).pluck(:id).to_set
    bad_ids.each do |bad_id|
      klass.new(id: bad_id).remove_from_index
    end
  end

  def klass
    @klass ||= Kernel.const_get(class_name)
  end

end