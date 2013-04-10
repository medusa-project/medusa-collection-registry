module ActiveDateChecker
  def check_active_dates
    if self.active_end_date.present? and self.active_start_date.present? and (self.active_end_date < self.active_start_date)
      errors.add(:active_start_date, 'Start date must not be later than end date.')
      errors.add(:active_end_date, 'Start date must not be later than end date.')
    end
  end
end