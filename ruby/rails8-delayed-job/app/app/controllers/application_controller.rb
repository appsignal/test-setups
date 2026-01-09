class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # before_action do
  #   Rails.logger.info("======== Request start")
  # end
  # after_action do
  #   Rails.logger.info("======== Request done")
  # end
end
