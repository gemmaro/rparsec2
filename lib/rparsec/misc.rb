# frozen_string_literal: true

module RParsec

  #
  # Helpers for defining ctor.
  #
  module DefHelper # :nodoc:
    def def_ctor(*vars)
      define_method(:initialize) do |*params|
        vars.zip(params) do |var, param|
          instance_variable_set("@#{var}", param)
        end
      end
    end

    def def_readable(*vars)
      attr_reader(*vars)
      def_ctor(*vars)
    end
  end

end # module
