module PuntoPagos
  # Public: Manages the notification process.
  class Notification
    def initialize env = nil
      @env = env
      @@config ||= PuntoPagos::Config.new(@env)
      @@function = "transaccion/notificar"
    end

    # Public: Validates the message sent by PuntoPagos in the
    # notification process.
    #
    # headers - The headers of the request as a Hash.
    # params  - The params Hash.
    #
    # Returns true or false.
    def valid? headers, params
      timestamp = get_timestamp headers

      message = create_message params["token"], params["trx_id"], params["monto"], timestamp
      authorization = Authorization.new(@env)
      signature = authorization.sign(message)
      signature == pp_signature(headers)

    end

    private

    # Internal: Creates the message to be signed which will be
    # compared against the one that PuntoPagos sends.
    #
    # token     - PuntoPagos transaction unique token.
    # trx_id    - Your transaction unique id.
    # amount    - The transaction amount.
    # timestamp - timestamp
    #
    # Returns a message as a String.
    def create_message token, trx_id, amount, timestamp
      @@function + "\n" + token + "\n" + trx_id + "\n" + amount + "\n" + timestamp
    end

    # Internal: Gets the signature out of the Autorizacion HTTP Header.
    #
    # headers - request headers as a Hash.
    #
    # Returns the Autorizacion HTTP Header value.
    def pp_signature headers
      headers['Autorizacion']
    end

    # Internal: Gets the timestamp out of the Fecha HTTP Header.
    #
    # headers - request headers as a Hash.
    #
    # Returns the Fecha HTTP Header value.
    def get_timestamp headers
      headers['Fecha']
    end
  end
end