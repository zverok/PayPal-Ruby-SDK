require 'logger'

module PayPal::SDK::Core
  # Include Logging module to provide logger functionality.
  # == Configure logger
  #   Logging.logger = Logger.new(STDERR)
  #
  # == Example
  #   include Logger
  #   logger.info "Debug message"
  module Logging

    # Get logger object
    def logger
      @logger ||= Logging.logger_for(self.class.name)
    end

    def log_event(message, start_time, end_time = Time.now)
      duration = sprintf("%.3f", end_time - start_time)
      logger.info "[#{duration}] #{message}"
    end

    # Use a hash class-ivar to cache a unique Logger per class
    @loggers  = {}

    class << self

      # Get or Create logger object based on Class
      def logger_for(classname)
        @loggers[classname] ||= configure_logger_for(classname)
      end

      # Create logger object for the given class
      # === Argument
      # * <tt>classname</tt> -- Class name for logger to create
      def configure_logger_for(classname)
        new_logger = logger.dup
        new_logger.progname = classname
        new_logger
      end

      # Get or Create configured logger based on the default environment configuration
      def logger
        @logger ||= Logger.new(Config.config.logfile || STDERR)
      end

      # Set logger directly and clear the loggers cache.
      # === Attributes
      # * <tt>logger</tt> -- Logger object
      # === Example
      #   Logging.logger = Logger.new(STDERR)
      def logger=(logger)
        @loggers = {}
        @logger  = logger
      end

    end
  end

end

