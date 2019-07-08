#!/usr/bin/env ruby

require 'json'
require "../lib/group_address"
require '../lib/model'
require '../lib/generic_on_off'

class Provisioner
  attr_accessor :devices_unprovisioned
  attr_reader :app_key

  def initialize(command)
    @cmd = command
    @devices_unprovisioned = []
    # [{id: 1, name: "home"}]
    @net_keys = []
    # [{id: 1, name: "user", :net_id: 0}]
    @app_keys = []
    @busy = false

    @models = []
    @unicast_address = 0
  end

  def discover_unprovisioned(period)

    t = Thread.new(period) do |period|

      @cmd.new_command("discover_unprovisioned on")

      start_time = Time.now
      while ((Time.now - start_time) * 1000.0 < period * 1000)
        unless @cmd.response_ready?
          sleep 0.01
          next
        end

        line = @cmd.response_gets

        line.scan(/Device\s+UUID:\s+([0-9A-Fa-f]{32})/) do |match|
          uuid = match.shift
          @devices_unprovisioned.push uuid
          # TODO: Notice that a new device is descovered, maybe a callback
        end

      end

      @cmd.processed

      @cmd.new_command_without_response("discover_unprovisioned off")
      @cmd.processed
    end

  end

  def app_key_add(index, name)
    # @app_key[name.to_sym] = @app_keys.length + 1
    # @app_keys.push app_key
    app_key[:index] = index
    app_key[:name] = name
    app_key[:net_key_index] = 0
    @app_keys.push app_key
  end

  def get_app_key_index(name)
      @app_key[name.to_sym]
  end

  def provision(uuid, ob_code)

    0x0010
  end

  def reload_mesh_info
    @cmd.new_command("mesh-info")
    json = ""

    json_begin = json_end = false

    loop do
      line = @cmd.response_gets(1000)
      case line
      when /\{/
        json_begin = true
      when /\}/
        json_end = true
      end

      if json_begin && !json_end
        json += line
      else
        break
      end
    end

    @cmd.processed

    JSON.parse(json)
  end

  def pub_set(element_address, publish_address, app_key_index, model_id)

    @cmd.new_command("pub set #{element_address} #{publish_address} #{app_key_index} #{model_id} ")
    model_pub_set(element_address, publish_address, model_id)
  end

  def sub_add(element_address, subscribe_address, model_id)

  end


private

  def model_pub_set(element_address, publish_address, model_id)
    @models.each do |model|
      if model.id == model_id
        model.pub_set(element_address, publish_address)
        return
      end
    end

    name = Model.get_model_class_name(model_id)
    if name
      model_class = Object.const_get(name)
      if model_class
        model = model_class.new
        model.pub_set(element_address, publish_address)
        @models.push model
      end

    end
  end

end