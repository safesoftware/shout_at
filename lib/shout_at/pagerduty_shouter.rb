module ShoutAt
  class PagerdutyShouter < Shouter

    def initialize(group, level, opts)
      super(group, level)
      @service_key = opts['service_key']
      raise ArgumentError.new("Service key must be provided for pagerduty shouters") if @service_key.blank?
    end

    def client
      @client ||= Pagerduty.new(@service_key)
    end

    # Pagerduty specific args
    # incident_key: Unique key for incident
    # details: key value pairs forwarded to pagerduty
    def shout(message, args = {})
      super
      client_url = @url || "https://#{SETTINGS['host']}"
      message_arguments = {
          client: "FME Cloud",
          incident_key: SecureRandom.hex,
          client_url: client_url,
          details: {
              subject: @subject,
              environment: Rails.env,
              group: @group,
              level: @level
          }
      }.deep_merge(args)

      client.trigger(
          message,
          message_arguments
      )
    end

  end
end