require_relative './base'

module Response
  class Know < Base
    RESPONSE_CODE_MESSAGE_HASH = {
      '200' => 'Success',
      '404' => 'Not found',
      '301' => 'Permanent redirect',
      '302' => 'Temporary redirect'
    }

    def code
      response.code
    end

    def know?
      true
    end

    def message
      RESPONSE_CODE_MESSAGE_HASH[code]
    end
  end
end
