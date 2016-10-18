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

  def all_monthly_stats
    db_stats = stats_by_month
    count = 0
    size = 0
    date = db_stats.keys.first
    Hash.new.tap do |h|
      while true
        if db_stats[date]
          count += db_stats[date][:count]
          size += db_stats[date][:size]
        end
        h[date] = {count: count, size: size}
        date = date + 1.month
        break if date > Date.today
      end
    end
  end

  protected

  def years_for_stats
    start = CfsFile.order('created_at asc').first.created_at.to_date
    current = Date.today
    last_start_of_year = if current.month >= 7
                           current.change(day: 1, month: 7, year: current.year + 1)
                         else
                           current.change(day: 1, month: 7, year: current.year)
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
    sql = <<SQL
    SELECT COALESCE(SUM(COALESCE(count,0)), 0) AS count, COALESCE(SUM(COALESCE(size,0)),0) AS size FROM timeline_stats
    WHERE month >= '#{start}' AND month < '#{finish}'
SQL
    CfsFile.connection.select_all(sql).first.to_hash.merge(start: start, finish: finish).with_indifferent_access.tap do |hash|
      hash[:size] ||= 0
      hash[:size] = hash[:size].to_i
    end
  end

  #this gets us the size and count by month (in order) as a hash keyed on the month
  def stats_by_month
    sql = <<SQL
    SELECT month, count, size FROM timeline_stats ORDER BY month ASC
SQL
    hashes = CfsFile.connection.select_all(sql).to_hash
    Hash.new.tap do |h|
      hashes.each do |month_info|
        day = Date.parse(month_info['month'])
        h[day] = {count: month_info['count'].to_i, size: month_info['size'].to_i}
      end
    end
  end

end