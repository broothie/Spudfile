module Spud
  class Options
    BOOLEANS = %i[help files debug]

    BOOLEANS.each do |name|
      attr_accessor name
      define_method("#{name}?") { !!send(name) }
    end

    def watches
      @watches ||= []
    end
  end
end
