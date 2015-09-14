require 'airbrake'

module ShoutAt
  class AirbrakeShouter < Shouter

    def initialize(group, level, opts)
      super(group, level)
    end

    def shout(message, args = {})
      super
      if @exception
        Airbrake.notify @exception, parameters: args.deep_merge({incident_message: message, level: @level, group: @group})
      else
        Airbrake.notify(ShoutAt::IncidentReport.new(message), parameters: args.deep_merge({level: @level, group: @group}))
      end
    end

  end
end