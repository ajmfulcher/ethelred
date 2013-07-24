class JSONHelper
  def self.normalize_array obj
    if obj.class == Array
      obj
    else
      [obj, ]
    end
  end
end
