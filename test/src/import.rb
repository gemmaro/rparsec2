$: << File.join(__dir__, "../../lib")

def import *names
  names.each { |lib| require "rparsec/#{lib}" }
end
