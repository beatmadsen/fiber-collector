# frozen_string_literal: true
class Fiber
  module Collector
    class All
      def initialize(procs)
        @tasks = procs.map { Task.new(_1) }
      end

      def wait(timeout)
        raise "must run on non-blocking fiber" if Fiber.current.blocking?
        @tasks.each do |task|
          Fiber.schedule { task.run }
        end
        if timeout.nil?
          sleep 0.001 until @tasks.all?(&:done?)
        else
          elapsed = 0
          until @tasks.all?(&:done?)
            task = @tasks.find { |t| t.error }            
            unless task.nil?
              raise task.error
            end
            t = 0.001
            sleep t
            elapsed += t
            raise "timeout" if elapsed > timeout
          end
        end
        @tasks.map { |t| t.error && raise(t.error) || t.result }
      end
    end
  end
end
