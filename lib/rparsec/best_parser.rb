require "rparsec/parser"

module RParsec
  class BestParser < Parser # :nodoc:
    init :alts, :longer
    def _parse ctxt
      best_result = nil
      best_ind = -1
      err_ind = -1
      err_pos = -1
      ind = ctxt.index
      result = ctxt.result
      err = ctxt.error
      for p in @alts
        ctxt.reset_error
        ctxt.index = ind
        ctxt.result = result
        if p._parse(ctxt)
          err = nil
          now_ind = ctxt.index
          if best_ind == -1 || (now_ind != best_ind && @longer == (now_ind > best_ind))
            best_result = ctxt.result
            best_ind = now_ind
          end
        elsif best_ind < 0 # no good match found yet.
          if ctxt.error.index > err_pos
            err_ind = ctxt.index
            err_pos = ctxt.error.index
          end
          err = Failures.add_error(err, ctxt.error)
        end
      end
      if best_ind >= 0
        ctxt.index = best_ind
        return ctxt.retn(best_result)
      else
        ctxt.error = err
        ctxt.index = err_ind
        return false
      end
    end
  end
end
