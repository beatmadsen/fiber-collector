
class Fiber
  module Collector
    class Task
      attr_reader :state, :error, :result

      def initialize(proc)
        @state = :waiting
        @proc = proc
      end

      def done?
        @state == :done
      end

      def run
        @state = :running
        @result = @proc.call
      rescue StandardError => e
        @error = e
      ensure
        @state = :done
      end
    end
  end
end