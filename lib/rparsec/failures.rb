module RParsec
  class Failures # :nodoc:
    def self.add_error(err, e)
      return e if err.nil?
      return err if e.nil?
      cmp = compare_error(err, e)
      return err if cmp > 0
      return e if cmp < 0
      err
    end

    class << self
      private

      def get_first_element(err)
        while err.kind_of?(Array)
          err = err[0]
        end
        err
      end

      def compare_error(e1, e2)
        e1 = get_first_element(e1)
        e2 = get_first_element(e2)
        return -1 if e1.index < e2.index
        return 1 if e1.index > e2.index
        0
      end
    end
  end
end
