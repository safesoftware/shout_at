module ShoutAt
  class Shouter

    def initialize(group, level)
      @group = group
      @level = level
    end

    # Global arguments
    # subject: brief description of the incident (optional)
    # url: URL providing more information about the incident (optional)
    # exception: Exception object, used to print the backtrace (optional)
    def shout(message, args = {})
      @subject = args[:subject] || (message.length > 33 ? "#{message[0..30]}..." : message)
      @url = args[:url]
      @exception = args[:exception]
      args.delete(:exception)
      Rails.logger.info "Shouter::#{@group.camelize}::#{@level.camelize}: #{@subject}: #{message}"
      Rails.logger.warn "Exception: #{@exception}" if @exception
      Rails.logger.warn @exception.backtrace.join("\n") if @exception && @exception.backtrace
      Rails.logger.debug "Shouter::#{@group.camelize}::#{@level.camelize}: Args: #{args}"
    end

  end
end