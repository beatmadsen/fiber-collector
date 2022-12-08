# frozen_string_literal: true
class Fiber
  module Collector
    class Race
      def initialize(procs)
        @tasks = procs.map { Task.new(_1) }
      end

      def wait(timeout)
        raise "must run on non-blocking fiber" if Fiber.current.blocking?
        @tasks.each do |task|
          Fiber.schedule { task.run }
        end
        if timeout.nil?
          loop do
            task = @tasks.find { |t| t.done? }
            unless task.nil?
              raise task.error unless task.error.nil?
              return task.result
            end
            sleep 0.001
          end
        else
          elapsed = 0
          loop do
            task = @tasks.find { |t| t.done? }
            unless task.nil?
              raise task.error unless task.error.nil?
              return task.result
            end
            t = 0.001
            sleep t
            elapsed += t
            raise "timeout" if elapsed > timeout
          end          
        end
      end
    end
  end
end
