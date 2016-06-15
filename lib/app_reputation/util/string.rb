class String
  def set_param(placeholder, value)
    self.gsub("$[#{placeholder.to_s}]", value.to_s)
  end
end
