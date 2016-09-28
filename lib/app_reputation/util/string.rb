class String
  def set_param(placeholder, value)
    self.gsub("$[#{placeholder}]", value.to_s)
  end
  
  def escape_uri
    `echo #{self.inspect}`.chomp
  end
end
