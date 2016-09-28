class String
  def set_param(placeholder, value)
    self.gsub("$[#{placeholder}]", value.to_s)
  end
  
  def escape_uri
    self.gsub(/\\x([0-9A-Fa-f]{2})/) { $~.captures.first.to_i(16).chr(Encoding::UTF_8) }
  end
end
