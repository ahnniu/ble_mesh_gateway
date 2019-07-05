#!/usr/bin/env ruby

class Command
  attr_accessor :processing
  alias is_processing? processing

  def initialize(server)
    @server = server
    @processing = false
    @request = []
    @response = []
    send
    listen
  end

  def send
    t = Thread.new do
      loop do
        next if @request.empty?
        msg = @request.shift
        @server.puts(msg)
      end
    end
  end

  def listen
    t = Thread.new do
      loop do
        msg = @server.gets.chomp
        @response.push(msg)
      end
    end
  end

  def new_command(args)
    return if @processing
    @response.clear
    @request.push(args)
    @processing = true
  end

  def new_command_without_response(args)
    return if @processing
    @request.push(args)
  end

  def processed
    @response.clear
    @processing = false
  end

  def response_ready?
    !@response.empty?
  end

  def response_gets(timeout_ms = 0)

    return @response.shift if timeout_ms <= 0

    start_time = Time.now
    while ((Time.now - start_time) * 1000.0 < timeout_ms)
      if @response.empty?
        sleep 0.01
        next
      end
      return @response.shift
    end

    nil
  end

end