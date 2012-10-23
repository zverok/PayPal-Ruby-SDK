require 'date'

module PayPal::SDK::Core
  module API
    module DataTypes

      module SimpleTypes
        class String < ::String
          def self.new(string = "")
            string.is_a?(::String) ? super : super("")
          end
        end

        class Integer < ::Integer
          def self.new(number)
            number.to_i
          end
        end

        class Float < ::Float
          def self.new(float)
            float.to_f
          end
        end

        class Boolean
          def self.new(boolean)
            !!boolean
          end
        end

        class DateTime < ::DateTime
          def self.new(date_time)
            date_time.is_a?(::DateTime) ? date_time : parse(date_time)
          end
        end
      end

    end
  end
end
