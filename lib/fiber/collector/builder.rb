# frozen_string_literal: true
require_relative 'builder/all'
require_relative 'builder/any'
require_relative 'builder/race'
require_relative 'builder/task'

class Fiber
  module Collector    
    class Builder
      def initialize
        @blocks = []
      end

      def schedule(&block)
        @blocks << block
        self
      end

      def and(...)
        schedule(...)
      end

      def all(timeout: nil)
        All.new(@blocks).wait(timeout)
      end
      
      def any(timeout: nil)
        Any.new(@blocks).wait(timeout)
      end

      def race(timeout: nil)
        Race.new(@blocks).wait(timeout)
      end
    end
  end
end
