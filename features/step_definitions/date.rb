def fill_in_date_select(year, month, day, selector_root)
  select year, :from => "#{selector_root}_1i"
  select month.to_i.to_s, :from => "#{selector_root}_2i"
  select day.to_i.to_s, :from => "#{selector_root}_3i"
end