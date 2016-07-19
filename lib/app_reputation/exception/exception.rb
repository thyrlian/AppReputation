module AppReputation
  module Exception
    class UnauthorizedError < RuntimeError
      def initialize(account = nil)
        if account
          super("Cannot authorize account: #{account}")
        else
          super('Cannot authorize')
        end
      end
    end
  end
end
