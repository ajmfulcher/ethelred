class Navigation
  attr_reader :items
  
  def initialize items
    @items = items.sort
  end
end

class NavigationItem
  attr_reader :title, :path, :order
  
  def initialize title, path, order=0
    @title = title
    @path = path
    @order = order
  end
  
  def active_for? request
    request.path == @path
  end
  
  def == other
    @title == other.title
    @path == other.path
  end
  
  def <=> other
    @order <=> other.order
  end
end