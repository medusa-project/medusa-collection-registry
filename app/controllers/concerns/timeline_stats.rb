require 'active_support/concern'

module TimelineStats
  extend ActiveSupport::Concern

  def yearly_stats
    years_for_stats.collect do |start|
      finish = start + 1.year
      stats_for_period(start, finish)
    end
  end

  def monthly_stats
    months_for_stats.collect do |start|
      finish = start + 1.month
      stats_for_period(start, finish)
    end
  end

  protected

  def years_for_stats
    start = CfsFile.order('created_at asc').first.created_at.to_date
    current = Date.today
    last_start_of_year = if current.month >= 7
                           current.change(day: 1, month: 7)
                         else
                           current.change(day: 1, month: 7, year: current.year - 1)
                         end
    Array.new.tap do |years|
      while last_start_of_year >= start
        years.unshift(last_start_of_year)
        last_start_of_year = last_start_of_year - 1.year
      end
    end.collect { |x| x - 1.year }
  end

  def months_for_stats
    start = Date.today.change(day: 1)
    (0..11).collect { |offset| start - offset.months }.reverse
  end

  def stats_for_period(start, finish)
    sql = CfsFile.where('created_at >= ?', start).where('created_at < ?', finish).select('COUNT(*) AS count, SUM(size) AS size').to_sql
    CfsFile.connection.select_all(sql).first.to_hash.merge(start: start, finish: finish).with_indifferent_access.tap do |hash|
      hash[:size] ||= 0
      hash[:size] = hash[:size].to_i
    end
  end

end