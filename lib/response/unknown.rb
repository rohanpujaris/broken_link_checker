require_relative './base'

module Response
  class Unknown < Base
    def code
      nil
    end

    def known?
      false
    end

    def message
      response.message
    end
  end
end
