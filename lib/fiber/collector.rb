# frozen_string_literal: true

require_relative 'collector/builder'
require_relative 'collector/version'

class Fiber
  module Collector
    def self.schedule(&block)
      Builder.new.schedule(&block)
    end

    class Error < StandardError; end
  end
end
