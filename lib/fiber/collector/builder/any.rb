# frozen_string_literal: true
class Fiber
  module Collector
    class Any
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
            task = @tasks.find { |t| t.done? && t.error.nil? }
            return task.result unless task.nil?
            raise @tasks.first.error if @tasks.all? { |t| t.done? && t.error }
            sleep 0.001
          end
        else
          elapsed = 0
          loop do
            task = @tasks.find { |t| t.done? && t.error.nil? }
            return task.result unless task.nil?
            raise @tasks.first.error if @tasks.all? { |t| t.done? && t.error }
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
