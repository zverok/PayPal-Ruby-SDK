module PayPal::SDK::Core
  module API
    module DataTypes

      class Enum < SimpleTypes::String
        class << self
          def options
            @options ||= []
          end

          def options=(options)
            @options = options
            @options.each do |option|
              const_set(option, option)
            end
          end
        end
      end

    end
  end
end