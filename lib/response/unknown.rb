require_relative './base'

module Response
  class Unkow < Base
    def code
      nil
    end

    def know?
      false
    end

    def message
      response.message
    end
  end
end
