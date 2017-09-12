module RedFlagsHelper

  def red_flags_table_headers
    if safe_can?(:mass_unflag, RedFlag)
      %w(Type Label Priority Status Time Message \  Actions)
    else
      %w(Type Label Priority Status Time Message Actions)
    end
  end

end