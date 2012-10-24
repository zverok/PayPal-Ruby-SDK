require 'date'

module PayPal::SDK::Core
  module API

    module DataTypes

      # Create attributes and restrict the object type.
      # == Example
      #   class ConvertCurrencyRequest < Core::API::DataTypes::Base
      #     object_of :baseAmountList,        CurrencyList
      #     object_of :convertToCurrencyList, CurrencyCodeList
      #     object_of :countryCode,           String
      #     object_of :conversionType,        String
      #   end
      class Base

        include SimpleTypes

        class << self

          # Get Attribute list
          def attributes
            @attributes ||= 
              begin
                parent_attributes = superclass.instance_variable_get("@attributes")
                parent_attributes ? parent_attributes.dup : {}
              end
          end

          # Add attribute
          # === Arguments
          # * <tt>name</tt>  -- attribute name
          # * <tt>options</tt> -- options
          def add_attribute(name, options = {})
            name = name.to_sym
            attributes[name] = options
            attr_accessor name
            snakecase_name = snakecase(name)
            alias_method snakecase_name, name
            alias_method "#{snakecase_name}=", "#{name}="
            alias_method "@#{name}=", "#{name}="
            if options[:namespace]
              alias_method "#{options[:namespace]}:#{name}=", "#{name}="
              alias_method "@#{options[:namespace]}:#{name}=", "#{name}="
            end
          end


          # Fields list for the DataTye
          def members
            @members ||= 
              begin
                parent_members = superclass.instance_variable_get("@members")
                parent_members ? parent_members.dup : {}
              end
          end

          # Add Field to class variable hash and generate methods
          # === Example
          #   add_member(:errorMessage, String)  # Generate Code
          #   # attr_reader   :errorMessage
          #   # alias_method  :error_message,  :errorMessage
          #   # alias_method  :error_message=, :errorMessage=
          def add_member(member_name, klass, options = {})
            member_name = member_name.to_sym
            members[member_name] = options.merge( :type => klass )
            attr_reader member_name
            snakecase_name = snakecase(member_name)
            alias_method snakecase_name, member_name
            alias_method "#{snakecase_name}=", "#{member_name}="
            alias_method "#{options[:namespace]}:#{member_name}=", "#{member_name}=" if options[:namespace]
          end

          # define method for given member and the class name
          # === Example
          #   object_of(:errorMessage, ErrorMessage) # Generate Code
          #   # def errorMessage=(options)
          #   #   @errorMessage = ErrorMessage.new(options)
          #   # end
          #   # add_member :errorMessage, ErrorMessage
          def object_of(key, klass, options = {})
            define_method "#{key}=" do |value|
              instance_variable_set("@#{key}", convert_object(value, klass))
            end
            add_member(key, klass, options)
          end

          # define method for given member and the class name
          # === Example
          #   array_of(:errorMessage, ErrorMessage) # It Generate below code 
          #   # def errorMessage=(array)
          #   #   @errorMessage = array.map{|options| ErrorMessage.new(options) }
          #   # end
          #   # add_member :errorMessage, ErrorMessage
          def array_of(key, klass, options = {})
            define_method "#{key}=" do |value|
              instance_variable_set("@#{key}", convert_array(value, klass))
            end
            add_member(key, klass, options)
          end

          # Generate snakecase string.
          # === Example
          # snakecase("errorMessage")
          # # error_message
          def snakecase(string)
            string.to_s.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/([A-Z])([A-Z][a-z])/, '\1_\2').downcase
          end

        end

        # Initialize options.
        def initialize(options = {})
          if options.is_a? Hash
            options.each do |key, value|
              begin
                send("#{key}=", value)
              rescue TypeError => error
                raise TypeError, "Invalid data(#{value.inspect}) for #{self.class.name}.#{key} member"
              end
            end
          elsif members[:value]
            self.value = options
          else
            raise ArgumentError, "invalid data(#{options.inspect}) for #{self.class.name} class"
          end
        end

        # Create array of objects.
        # === Example
        # covert_array([{ :amount => "55", :code => "USD"}], CurrencyType)
        def convert_array(array, klass)
          if array.is_a? Array
            array.map do |object|
              convert_object(object, klass)
            end
          else
            [ convert_object(array, klass) ]
          end
        end

        # Create object based on given data.
        # === Example
        # covert_array({ :amount => "55", :code => "USD"}, CurrencyType )
        def convert_object(object, klass)
          object.nil? or object.is_a?(klass) ? object : klass.new(object)
        end

        # Alias instance method for the class method.
        def members
          self.class.members
        end

        # Get configured member names
        def member_names
          members.keys
        end

        # Create Hash based configured members
        def to_hash
          member_names.inject({}) do |hash, member|
            value = send(member)
            hash[hash_key(member)] = value_to_hash(value) if value
            hash
          end
        end

        def hash_key(key)
          members[key][:namespace] ? "#{members[key][:namespace]}:#{key}".to_sym : key
        end

        # Covert the object to hash based on class.
        def value_to_hash(value)
          case value
          when Array
            value.map{|object| value_to_hash(object) }
          when Base
            value.to_hash
          else
            value
          end
        end
      end
    end
  end
end
