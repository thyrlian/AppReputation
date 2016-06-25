class String
  def set_param(placeholder, value)
    self.gsub("$[#{placeholder}]", value.to_s)
  end
end
