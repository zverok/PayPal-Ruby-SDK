require 'date'

module PayPal::SDK::Core
  module API
    module DataTypes

      module SimpleTypes
        class String < ::String
          def self.new(string = "")
            string.is_a?(::String) ? super : super(string.to_s)
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
            ( boolean == 0 || boolean == "" || boolean =~ /^(false|f|no|n|0)$/i ) ? false : !!boolean
          end
        end

        class DateTime < ::DateTime
          def self.new(date_time)
            date_time.is_a?(::DateTime) ? date_time : parse(date_time.to_s)
          end
        end
      end

    end
  end
end
