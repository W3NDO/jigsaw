import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :demo, Demo.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "glJ+wkeOQoycmyzvRmRqOUt/1lrMm6YYeYrPtLJqdYGh4XtxmmXSArzs1T0CPMj+",
  server: false
