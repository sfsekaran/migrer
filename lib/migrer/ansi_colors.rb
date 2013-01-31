class String
  def migrer_green
    "\033[32m#{self}\033[0m"
  end

  def migrer_red
    "\033[31m#{self}\033[0m"
  end

  def migrer_yellow
    "\033[33m#{self}\033[0m"
  end
end
