class User < ActiveRecord::Base
  def do_stuff!
    self.email = "#{SecureRandom.uuid}@foo.com"
    save!
  end

  def do_stuff_with_error!
    raise "uh oh"
  end
end
