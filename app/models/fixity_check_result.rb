class FixityCheckResult < ApplicationRecord
  belongs_to :cfs_file
  enum status: {ok: 0, bad: 1, not_found: 2}
end
