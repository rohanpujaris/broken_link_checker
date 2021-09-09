module Response
  class Base
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def known?
      raise "Define method 'know' in class #{self.class.name}"
    end

    def code
      raise "Define method 'code' in class #{self.class.name}"
    end

    def message
      raise "Define method 'message' in class #{self.class.name}"
    end
  end
end
