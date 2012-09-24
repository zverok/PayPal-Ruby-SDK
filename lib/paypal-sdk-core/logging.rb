require 'logger'
module PayPal::SDK::Core
  module Logging
  
    def logger
      @logger ||= Logging.logger_for(self.class.name)
    end
    # Use a hash class-ivar to cache a unique Logger per class
    @loggers = {}
  
    @out = STDOUT
  
    class << self
  
      def logger_for(classname)
        configure(Config.config.logfile)
        @loggers[classname] ||= configure_logger_for(classname)
  
      end
  
      def configure_logger_for(classname)
        logger = Logger.new(@out)
        logger.progname = classname
        logger
      end
      
      def configure(log_file_name)
        if log_file_name
          @out = log_file_name
        end
      end
      
    end
    
  end
  
end
  
