module ShoutAt
  class EmailShouter < Shouter

    def initialize(group, level, opts)
      super(group, level)
      @to = opts['to']
      raise ArgumentError.new("Recipient email address must be provided for email shouters") if @to.blank?
    end

    def shout(message, args = {})
      super
      IncidentMailer.incident(@to, @subject, message, @url).deliver
    end

  end
end