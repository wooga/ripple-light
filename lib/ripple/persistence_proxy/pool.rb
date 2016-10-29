require 'thread'
require 'em-synchrony/thread'
require 'set'

# PersistenceProxy::Pool is EM Fiber-Aware re-entrant thread-safe resource pool that was
# extracted Innertube
# (https://github.com/basho/innertube).
# @see Pool
module PersistenceProxy
  # An EM Fiber-Aware re-entrant thread-safe resource pool that generates new resources on
  # demand.
  # @private
  class Pool
    # Raised when a taken element should be deleted from the pool.
    class BadResource < RuntimeError; end

    # An element of the pool. Comprises an object with an owning
    # thread. Not usually needed by user code, and should not be
    # modified outside the {Pool}'s lock.
    class Element
      attr_reader :object, :owner

      # Creates a pool element
      # @param [Object] object the resource to wrap into the pool element
      def initialize(object)
        @object = object
        @owner = nil
      end

      # Claims this element of the pool for the current Thread.
      # Do not call this manually, it is only used from inside the pool.
      def lock
        @owner = Thread.current
      end

      # @return [true,false] Is this element locked/claimed?
      def locked?
        !unlocked?
      end

      # Releases this element of the pool from the current Thread.
      def unlock
        @owner = nil
      end

      # @return [true,false] Is this element available for use?
      def unlocked?
        owner.nil?
      end
    end

    # Creates a new resource pool.
    # @param [true,false] evented Wether to create and EM FiberAware pool or not
    # @param [Proc, #call] open a callable which allocates a new object for the
    #   pool
    # @param [Proc, #call] close a callable which is  called with an
    #   object before it is freed.
    def initialize(evented, open, close)
      @evented = evented
      @open = open
      @close = close
      @lock = new_mutex
      @iterator = new_mutex
      @element_released = new_condition_variable
      @pool = Set.new
    end

    # On each element of the pool, calls close(element) and removes it.
    # @private
    def clear
      each_element do |e|
        delete_element e
      end
    end
    alias :close :clear

    # Deletes an element of the pool. Calls the close callback on its object.
    # Not intended for external use.
    # @param [Element] e the element to remove from the pool
    def delete_element(e)
      @close.call(e.object)
      @lock.synchronize do
        @pool.delete e
      end
    end
    private :delete_element

    # Locks each element in turn and closes/deletes elements for which the
    # object passes the block.
    # @yield [object] a block that should determine whether an element
    #   should be deleted from the pool
    # @yieldparam [Object] object the resource
    def delete_if
      raise ArgumentError, "block required" unless block_given?

      each_element do |e|
        if yield e.object
          delete_element e
        end
      end
    end

    # Acquire an element of the pool. Yields the object. If all
    # elements are claimed, it will create another one.
    # @yield [resource] a block that will perform some action with the
    #   element of the pool
    # @yieldparam [Object] resource a resource managed by the pool.
    #   Locked for the duration of the block
    # @param [Proc, #call] :filter a callable which receives objects and has
    #   the opportunity to reject each in turn.
    # @param [Object] :default if no resources are available, use this object
    #   instead of calling #open.
    # @private
    def take(opts = {})
      raise ArgumentError, "block required" unless block_given?

      result = nil
      element = nil
      opts[:filter] ||= proc {|_| true }
      @lock.synchronize do
        element = @pool.find { |e| e.unlocked? && opts[:filter].call(e.object) }
        unless element
          # No objects were acceptable
          resource = opts[:default] || @open.call
          element = Element.new(resource)
          @pool << element
        end
        element.lock
      end
      begin
        result = yield element.object
      rescue BadResource
        delete_element element
        raise
      ensure
        # Unlock
        if element
          element.unlock
          @element_released.signal
        end
      end
      result
    end
    alias >> take

    # Iterate over a snapshot of the pool. Yielded objects are locked
    # for the duration of the block. This may block the current thread
    # until elements in the snapshot are released by other threads.
    # @yield [element] a block that will do something with each
    #   element in the pool
    # @yieldparam [Element] element the current element in the
    #   iteration
    def each_element
      targets = @pool.to_a
      unlocked = []

      @iterator.synchronize do
        until targets.empty?
          @lock.synchronize do
            @element_released.wait(@iterator) if targets.all? {|e| e.locked? }
            unlocked, targets = targets.partition {|e| e.unlocked? }
            unlocked.each {|e| e.lock }
          end

          unlocked.each do |e|
            begin
              yield e
            ensure
              e.unlock
            end
          end
        end
      end
    end

    # As each_element, but yields objects, not wrapper elements.
    # @yield [resource] a block that will do something with each
    #   resource in the pool
    # @yieldparam [Object] resource the current resource in the
    #   iteration
    def each
      each_element do |e|
        yield e.object
      end
    end

    # @return [Integer] the number of the resources in the pool
    def size
      @lock.synchronize { @pool.size }
    end

    private

    # Generates a new Mutex or an EM Fiber-Aware Mutex if the
    # code is running inside an EventMachine loop
    # @private
    # @return [Mutex] a mutex
    def new_mutex
      if @evented
        ::EventMachine::Synchrony::Thread::Mutex.new
      else
        Mutex.new
      end
    end

    # Generates a new ConditionVariable or an EM Fiber-Aware 
    # ConditionVariable if thecode is running inside an 
    # EventMachine loop
    # @private
    # @return [ConditionVariable] a condition_variable
    def new_condition_variable
      if @evented
        ::EventMachine::Synchrony::Thread::ConditionVariable.new
      else
        ConditionVariable.new
      end
    end
  end
end