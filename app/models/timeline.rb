class Timeline
  include ActiveModel::Model

  attr_accessor :timeline_stats

  def initialize(object: nil)
    if object.nil?
      self.timeline_stats = Timeline.base_for_system_totals
    else
      self.timeline_stats = Timeline.base_for_directories(directory_ids: object.timeline_directory_ids)
    end
  end

  def self.base_for_directories(directory_ids:)
    return [{ "month"=>"2021-01-01 00:00:00","count"=>0,"size"=>"0.0"}]  if directory_ids.nil? || directory_ids.empty?

    directory_id_strings = directory_ids.map(&:to_s)
    directory_list = directory_id_strings.join(",")
    filtered_by_directory = "SELECT id, created_at, size FROM cfs_files WHERE cfs_directory_id in (#{directory_list})"
    date_just_month = "SELECT id, date_trunc('month', created_at) AS month, size FROM (#{filtered_by_directory}) AS T"
    coalesce_sizes = "SELECT month, count(*) AS count, coalesce(sum(size), 0) AS size FROM (#{date_just_month}) AS S"
    sql = "#{coalesce_sizes} GROUP BY month ORDER BY month ASC"
    result =  CfsFile.connection.select_all(sql)
    result.map{ |row| row["size"] = row["size"].to_i}
    result
  end

  def self.base_for_system_totals
    sql = "SELECT month, count, size FROM timeline_stats ORDER BY month ASC"
    result = CfsFile.connection.select_all(sql)
    result.map{ |row| row["size"] = row["size"].to_i}
    result
  end

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
        h[date] = { count: count, size: size }
        date = date + 1.month
        break if date > Date.today
      end
    end
  end

  def years_for_stats
    start = CfsFile.order(:created_at).first.created_at.to_date
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
    subset = self.timeline_stats.select{ |row|  row["month"] >= "#{start}" && row["month"] <= "#{finish}" }
    count = subset.pluck("count").sum
    size = subset.pluck("size").sum
    size ||= 0
    count ||= 0
    result = ActiveSupport::HashWithIndifferentAccess.new
    result[:size] = size
    result[:count] = count
    result[:start] = start
    result[:finish] = finish
    result
  end

  #this gets us the size and count by month (in order) as a hash keyed on the month
  def stats_by_month
    hashes = self.timeline_stats
    Hash.new.tap do |h|
      hashes.each do |month_info|
        day = Date.parse(month_info['month'].to_s)
        h[day] = {count: month_info['count'].to_i, size: month_info['size'].to_i}
      end
    end
  end

end