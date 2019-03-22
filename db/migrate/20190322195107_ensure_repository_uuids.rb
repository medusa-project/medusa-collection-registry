#This is a bit of an abuse, but it seems like the best way to ensure that this happens - we're making
# repositories have uuids, so this migration will ensure that they do.
class EnsureRepositoryUuids < ActiveRecord::Migration[5.2]
  def change
    Repository.find_each do |repository|
      repository.ensure_uuid
    end
  end
end
