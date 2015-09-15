require 'slack-notifier'

module ShoutAt
  class SlackShouter < Shouter

    def initialize(group, level, opts)
      super(group, level)
      @web_hook = opts['web_hook']
      @icon_emoji = opts['icon_emoji'] || ':loudspeaker:'

      raise ArgumentError.new("Web hook must be set for slack shouters") if @web_hook.blank?
    end

    def client
      @client ||= Slack::Notifier.new @web_hook,
                                      username: "#{Rails.env}-#{@group}-#{@level}-shouter",
                                      icon_emoji: @icon_emoji
    end

    # Slack specific args
    # username: Modifies username
    # attachments: https://api.slack.com/docs/attachments
    # icon_emoji: Modifies emoji
    def shout(message, args = {})
      super
      args.deep_merge!({attachments: [create_exception_attachment(@exception)]}) if @exception
      client.ping "*#{@subject}*\n#{message}\n#{@url}", args
    end

    def create_exception_attachment(exception)
      trace = exception.backtrace.andand.join("\n")
      {
          fallback: trace,
          title: exception.message,
          text: "```#{trace}```",
          color: Rails.env.production? ? "danger" : "warning",
          mrkdwn_in: ["text"]
      }
    end

  end
end
