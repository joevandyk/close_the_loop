# Add these routes to lib/close_the_loop_web/router.ex
#
# In the router, add a pipeline and scope for health/platform endpoints:
#
#   pipeline :api do
#     plug :accepts, ["json"]
#   end
#
#   scope "/", CloseTheLoopWeb do
#     pipe_through :api
#
#     get "/health", HealthController, :health
#     get "/ready", HealthController, :ready
#     get "/version", HealthController, :version
#   end
#
# 
