require 'logger'

module PayPal::SDK::Core
  module Logging
  
    def logger
      @logger ||= Logging.logger_for(self.class.name)
    end
    
    # Use a hash class-ivar to cache a unique Logger per class
    @loggers  = {}
  
    class << self
  
      def logger_for(classname)
        @loggers[classname] ||= configure_logger_for(classname)
      end
  
      def configure_logger_for(classname)
        new_logger = logger.dup
        new_logger.progname = classname
        new_logger
      end
      
      def logger
        @logger ||= Logger.new(Config.config.logfile || STDERR)
      end
      
      def logger=(logger)
        @loggers = {}
        @logger  = logger
      end
      
    end
  end
  
end
  
