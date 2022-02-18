class ItemUpdater
  def update(item, attributes:)
    puts "update"
    sleep 0.3
  end
  appsignal_instrument_method :update

  def self.update_all(items, attributes:)
    items.each do |item|
      new.update(item, :attributes => attributes)
    end
    sleep 0.1
  end
  appsignal_instrument_class_method :update_all
end
