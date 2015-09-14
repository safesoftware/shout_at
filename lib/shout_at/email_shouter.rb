module ShoutAt
  class EmailShouter < Shouter

    def initialize(group, level, opts)
      super(group, level)
      @to = opts['to']
      raise ArgumentError.new("Recipient email address must be provided for email shouters") if @to.blank?
      @mailer = Object.const_get(opts['mailer_name'])
      raise ArgumentError.new("Mailer needs method 'shout'") unless @mailer.respond_to?(:shout)
    end

    def shout(message, args = {})
      super
      @mailer.shout(@to, @subject, message, @url).deliver
    end

  end
end