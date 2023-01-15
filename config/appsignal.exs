import Config

config :appsignal, :config,
  otp_app: :alternis,
  name: "alternis",
  push_api_key: System.fetch_env("APPSIGNAL_PUSH_API_KEY"),
  env: Mix.env()
