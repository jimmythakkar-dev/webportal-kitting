APP_CONFIG = YAML.load_file(Rails.root.join('config', 'config.yml'))[Rails.env]
AUTH_CONFIG = YAML.load_file(Rails.root.join('config', 'authorization.yml'))[Rails.env].freeze
begin
  APP_VERSION = `git describe --tags` unless defined? APP_VERSION
rescue
  "Unable to Fetch APP VERSION"
end