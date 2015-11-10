require "shout_at/version"

require 'rails'
require 'active_support/core_ext/module/attribute_accessors'
require 'shout_at/shouter'
require 'shout_at/airbrake_shouter'
require 'shout_at/pagerduty_shouter'
require 'shout_at/slack_shouter'
require 'shout_at/email_shouter'

module ShoutAt
  class IncidentReport < StandardError; end
  class ShoutAtError < StandardError; end

  class << self

    def init(opts, logger = nil)
      Shouter.logger = logger if logger
      opts.each do |group, group_opts|
        # Create new module for target group (e.g. ShoutAt::Support)
        group_module = Module.new
        self.const_set(group.camelize.to_sym, group_module)

        # Iterate through notification levels
        group_opts.each do |level, level_opts|
          # Create new shouter based on defined channel
          accessor_name = "notifier_#{group}_#{level}"
          self.send(:mattr_accessor, accessor_name.to_sym)
          self.send("#{accessor_name}=", build_shouter(group, level, level_opts))

          # Add notification method to group module
          method_builder(group_module, self.send("#{accessor_name}"), level, rescue_handler)
        end
      end
    end

    def rescue_handler=(proc)
      @rescue_handler = proc
    end

    def rescue_handler
      @rescue_handler ||= Proc.new do |e| 
        Shouter.logger.error e.message
        Shouter.logger.error e.backtrace.join("\n")
      end
    end

    private

    def method_builder(mod, accessor, level, rescue_handler)
      mod.define_singleton_method level do |message, opts = {}|
        begin
          accessor.shout(message, opts)
        rescue => e
          rescue_handler.call(e)
        end
      end
    end

    def build_shouter(group, level, opts)
      case opts['channel']
        when "log"
          return ShoutAt::Shouter.new(group, level)
        when "slack"
          return ShoutAt::SlackShouter.new(group, level, opts)
        when "pagerduty"
          return ShoutAt::PagerdutyShouter.new(group, level, opts)
        when "email"
          return ShoutAt::EmailShouter.new(group, level, opts)
        when "airbrake"
          return ShoutAt::AirbrakeShouter.new(group, level, opts)
        else
          raise ShoutAt::ShoutAtError.new("Undefined shouter channel #{opts['channel']}")
      end
    end
  end
end
