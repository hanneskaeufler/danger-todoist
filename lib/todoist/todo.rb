module Danger
  class Todo < Struct.new(:file, :text, :line_number)
  end
end
