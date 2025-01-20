# frozen_string_literal: true

module RParsec

  #
  # Helpers for defining ctor.
  #
  module DefHelper # :nodoc:
    def def_readable(*vars)
      attr_reader(*vars)

      define_method(:initialize) do |*params|
        vars.zip(params) do |var, param|
          instance_variable_set("@#{var}", param)
        end
      end
    end
  end

end # module
