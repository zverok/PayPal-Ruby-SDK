module PayPal::SDK::Core
  module API
    
    # Create attributes and restrict the object type.
    # == Example
    #   class ConvertCurrencyRequest < Core::API::DataType
    #     object_of :baseAmountList,        CurrencyList
    #     object_of :convertToCurrencyList, CurrencyCodeList
    #     object_of :countryCode,           String
    #     object_of :conversionType,        String
    #   end      
    class DataType
              
      class << self
        
        # Fields list for the DataTye
        def fields
          @fields ||= 
            begin
              parent_fields = superclass.instance_variable_get("@fields")
              parent_fields ? parent_fields.dup : {}
            end
        end
        
        # Add Field to class variable hash and generate methods
        # === Example
        #   add_field(:errorMessage, String)  # Generate Code
        #   # attr_reader   :errorMessage
        #   # alias_method  :error_message,  :errorMessage
        #   # alias_method  :error_message=, :errorMessage=
        def add_field(field_name, klass)
          field_name = field_name.to_sym
          fields[field_name] = klass
          attr_reader field_name
          snakecase_name = snakecase(field_name)
          alias_method snakecase_name, field_name
          alias_method "#{snakecase_name}=", "#{field_name}="            
        end
        
        # define method for given field and the class name
        # === Example
        #   object_of(:errorMessage, ErrorMessage) # Generate Code
        #   # def errorMessage=(options)
        #   #   @errorMessage = ErrorMessage.new(options)
        #   # end
        #   # add_field :errorMessage, ErrorMessage
        def object_of(key, klass)
          define_method "#{key}=" do |value|
            instance_variable_set("@#{key}", convert_object(value, klass))
          end
          add_field(key, klass)
        end
        
        # define method for given field and the class name
        # === Example
        #   array_of(:errorMessage, ErrorMessage) # It Generate below code 
        #   # def errorMessage=(array)
        #   #   @errorMessage = array.map{|options| ErrorMessage.new(options) }
        #   # end
        #   # add_field :errorMessage, ErrorMessage
        def array_of(key, klass)
          define_method "#{key}=" do |value|
            instance_variable_set("@#{key}", convert_array(value, klass))
          end
          add_field(key, klass)            
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
            send("#{key}=", value) unless key =~ /^@/
          end
        elsif fields[:value] and options.is_a? fields[:value]
          self.value = options
        else
          raise ArgumentError, "invalid data(#{options.inspect}) for #{self.class.name}"
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
      def fields
        self.class.fields
      end
      
      # Get configured field names
      def field_names
        fields.keys
      end
      
      # Create Hash based configured fields
      def to_hash
        field_names.inject({}) do |hash, field|
          value       = send(field)
          hash[field] = value_to_hash(value) if value
          hash
        end
      end
      
      # Covert the object to hash based on class.
      def value_to_hash(value)
        case value
        when Array
          value.map{|object| value_to_hash(object) }
        when DataType
          value.to_hash
        else
          value
        end
      end
    end
  end
end
