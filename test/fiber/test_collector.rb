# frozen_string_literal: true

require "test_helper"
require "async"

class Fiber::TestCollector < Minitest::Test
  
  def test_that_it_has_a_version_number
    refute_nil ::Fiber::Collector::VERSION
  end

  def test_all_executes_concurrently
    events = []
    create_task = ->(name, pause) { 
      puts "Creating task!"
      ->() { 
        events << [name, :started]
        sleep pause
        events << [name, :done]
      } 
    }
    Async do
      Fiber::Collector.schedule(&create_task.call(:a, 0.001))
          .and(&(create_task.call(:b, 0.002)))
          .and(&(create_task.call(:c, 0.003)))
          .all(timeout: 0.02)
    end.wait
    assert_equal [[:a, :started], [:b, :started], [:c, :started], [:a, :done], [:b, :done], [:c, :done]], events
  end
  
  def test_all_waits_for_all_callbacks
    results = nil
    Async do
      results = Fiber::Collector.schedule { sleep 0.010; 'a' }
          .and { sleep 0.005; 'b' } 
          .and { sleep 0.007; 'c' }
          .all(timeout: 0.02)    
    end.wait
    assert_equal ['a', 'b', 'c'], results
  end
  
  class XError < StandardError; end
  class YError < StandardError; end

  def test_all_fails_on_first_error
    assert_raises XError do 
      Async do
        Fiber::Collector.schedule { sleep 0.010; 'a' }
            .and { sleep 0.005; 'b' } 
            .and { sleep 0.006; raise XError }
            .and { sleep 0.007; raise YError }
            .all(timeout: 0.02)
      end.wait
    end    
  end

  def test_any_executes_concurrently
    events = []
    create_task = ->(name, pause) { 
      puts "Creating task!"
      ->() { 
        events << [name, :started]
        sleep pause
        events << [name, :done]
      } 
    }
    Async do
      Fiber::Collector.schedule(&create_task.call(:a, 0.001))
          .and(&(create_task.call(:b, 0.002)))
          .and(&(create_task.call(:c, 0.003)))
          .any(timeout: 0.02)
    end.wait
    assert_equal [[:a, :started], [:b, :started], [:c, :started], [:a, :done], [:b, :done], [:c, :done]], events
  end

  def test_any_returns_first_successful_callback
    result = nil
    Async do
      result = Fiber::Collector.schedule { sleep 0.010; 'a' }
          .and { sleep 0.001; raise 'e' }
          .and { sleep 0.005; 'b' } 
          .and { sleep 0.007; 'c' }
          .any(timeout: 0.02)    
    end.wait
    assert_equal 'b', result
  end

  def test_any_fails_when_all_callbacks_fail
    assert_raises XError do 
      Async do
        Fiber::Collector.schedule { sleep 0.010; raise XError  }
            .and { sleep 0.005; raise YError } 
            .and { sleep 0.006; raise YError }
            .and { sleep 0.007; raise YError }
            .any(timeout: 0.02)
      end.wait
    end    
  end

  def test_race_executes_concurrently
    events = []
    create_task = ->(name, pause) { 
      puts "Creating task!"
      ->() { 
        events << [name, :started]
        sleep pause
        events << [name, :done]
      } 
    }
    Async do
      Fiber::Collector.schedule(&create_task.call(:a, 0.001))
          .and(&(create_task.call(:b, 0.002)))
          .and(&(create_task.call(:c, 0.003)))
          .race(timeout: 0.02)
    end.wait
    assert_equal [[:a, :started], [:b, :started], [:c, :started], [:a, :done], [:b, :done], [:c, :done]], events
  end

  def test_race_raises_first_complete_callback
    assert_raises XError do 
      Async do
        Fiber::Collector.schedule { sleep 0.010; 'a' }
            .and { sleep 0.001; raise XError }
            .and { sleep 0.005; 'b' } 
            .and { sleep 0.007; raise YError }
            .race(timeout: 0.02)    
      end.wait
    end
  end

  def test_race_returns_result_of_first_complete_callback
    result = nil    
    Async do
      result = Fiber::Collector.schedule { sleep 0.010; raise XError }
          .and { sleep 0.001; 'a' }
          .and { sleep 0.005; 'b' } 
          .and { sleep 0.007; raise YError }
          .race(timeout: 0.02)    
    end.wait
    assert_equal 'a', result
  end  
end
