# app/middleware/appsignal_namespace_middleware.rb
class AppsignalNamespaceMiddleware
  def call(worker, msg, queue)
    # Set custom namespace before job execution
    Appsignal.set_namespace('test')

    # Continue with the job execution
    yield
  end
end
