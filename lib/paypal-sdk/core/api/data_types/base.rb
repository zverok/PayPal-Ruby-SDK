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

        HashOptions = { :attribute => true, :namespace => true, :symbol => true }
        ContentKey  = :value

        include SimpleTypes

        class << self

          # Add attribute
          # === Arguments
          # * <tt>name</tt>  -- attribute name
          # * <tt>options</tt> -- options
          def add_attribute(name, options = {})
            add_member(name, String, options.merge( :attribute => true ))
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
            define_method "#{member_name}=" do |value|
              object = options[:array] ? convert_array(value, klass) : convert_object(value, klass)
              instance_variable_set("@#{member_name}", object)
            end
            snakecase_name = snakecase(member_name)
            alias_method snakecase_name, member_name
            alias_method "#{snakecase_name}=", "#{member_name}="
            alias_method "#{options[:namespace]}:#{member_name}=", "#{member_name}=" if options[:namespace]
            if options[:attribute]
              alias_method "@#{member_name}=", "#{member_name}="
              alias_method "@#{options[:namespace]}:#{member_name}=", "#{member_name}=" if options[:namespace]
            end
          end

          # define method for given member and the class name
          # === Example
          #   object_of(:errorMessage, ErrorMessage) # Generate Code
          #   # def errorMessage=(options)
          #   #   @errorMessage = ErrorMessage.new(options)
          #   # end
          #   # add_member :errorMessage, ErrorMessage
          def object_of(key, klass, options = {})
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
            add_member(key, klass, options.merge(:array => true))
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
              rescue TypeError, ArgumentError => error
                raise TypeError, "#{error.message}(#{value.inspect}) for #{self.class.name}.#{key} member"
              end
            end
          elsif members[ContentKey]
            self.value = options
          else
            raise ArgumentError, "invalid data(#{options.inspect}) for #{self.class.name} class"
          end
        end

        # Create array of objects.
        # === Example
        # covert_array([{ :amount => "55", :code => "USD"}], CurrencyType)
        # covert_array({ "0" => { :amount => "55", :code => "USD"} }, CurrencyType)
        # covert_array({ :amount => "55", :code => "USD"}, CurrencyType)
        # # @return
        # # [ <CurrencyType#object @amount="55" @code="USD" > ]
        def convert_array(array, klass)
          if array.is_a? Array
            array.map do |object|
              convert_object(object, klass)
            end
          elsif array.is_a? Hash and array.keys.first =~ /^\d+$/
            array.map do |key, object|
              convert_object(object, klass)
            end
          else
            [ convert_object(array, klass) ]
          end
        end

        # Create object based on given data.
        # === Example
        # covert_object({ :amount => "55", :code => "USD"}, CurrencyType )
        # # @return
        # # <CurrencyType#object @amount="55" @code="USD" >
        def convert_object(object, klass)
          object.is_a?(klass) ? object : ( ( object.nil? or object == "" ) ? nil : klass.new(object) )
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
        def to_hash(options = {})
          options = HashOptions.merge(options)
          member_names.inject({}) do |hash, member|
            value = send(member)
            hash[hash_key(member, options)] = value_to_hash(value, options) if value
            hash
          end
        end

        # Generate Hash key for given member name based on configuration
        # === Example
        # hash_key(:amount) # @return :"ebl:amount"
        # hash_key(:type)   # @return :"@type"
        def hash_key(key, options = {})
          unless key == ContentKey
            member_option = members[key]
            key = "#{member_option[:namespace]}:#{key}" if member_option[:namespace] and options[:namespace]
            key = "@#{key}" if member_option[:attribute] and options[:attribute]
          end
          options[:symbol] ? key.to_sym : key.to_s
        end

        # Covert the object to hash based on class.
        def value_to_hash(value, options = {})
          case value
          when Array
            value.map{|object| value_to_hash(object, options) }
          when Base
            value.to_hash(options)
          else
            value
          end
        end
      end
    end
  end
end
