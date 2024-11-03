# frozen_string_literal: true

module RParsec

  #
  # Helpers for defining ctor.
  #
  module DefHelper # :nodoc:
    def def_ctor(*vars)
      define_method(:initialize) do |*params|
        vars.each_with_index do |var, i|
          instance_variable_set("@" + var.to_s, params[i])
        end
      end
    end

    def def_readable(*vars)
      attr_reader(*vars)
      def_ctor(*vars)
    end
  end

end # module
