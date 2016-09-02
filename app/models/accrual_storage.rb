class AccrualStorage < Storage

  def initialize
    super(config_roots: Settings.storage.accrual.roots.if_blank(Array.new))
  end

end