# frozen_string_literal: true

require 'serverspec'
require 'winrm'

set :backend, :winrm

opts = {
  user: ENV['domain_user'] || 'vagrant_service@sposcar.local',
  password: ENV['domain_user_password'] || 'Pass@word1!',
  endpoint: "http://#{ENV['TARGET_HOST']}:5985/wsman",
  operation_timeout: 300,
  transport: :plaintext
}

winrm = WinRM::Connection.new(opts)
winrm.logger.level = :info
Specinfra.configuration.winrm = winrm
