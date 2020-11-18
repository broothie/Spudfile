module Spud
  class Options
    BOOLEANS = %i[help files inspect debug]

    BOOLEANS.each do |name|
      attr_accessor name
      define_method("#{name}?") { !!send(name) }
    end

    def watches
      @watches ||= []
    end
  end
end
