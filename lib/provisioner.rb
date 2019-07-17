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

        if line =~ /No\sdefault\scontroller\savailable/
          error_msg = "No default controller available"
          puts "Error occurs: #{error_msg}"
          $dbus_object_provisioner_server.Error(error_msg)
          break
        end

        line.scan(/Device\s+UUID:\s+([0-9A-Fa-f]{32})/) do |match|
          uuid = match.shift
          @devices_unprovisioned.push uuid
          # TODO: Notice that a new device is descovered, maybe a callback
          puts "New device found"
          $dbus_object_provisioner_server.UnprovisionedDeviceDiscovered(uuid, "")
        end

      end

      @cmd.processed

      @cmd.new_command_without_response("discover_unprovisioned off")
      @cmd.processed
    end

  end

  def info_dev(uuid)
    @cmd.new_command("info #{uuid}")
    name = ""
    loop do
      line = @cmd.response_gets(2000)
      break unless line
      line.scan(/Name:\s([_A-Za-z0-9]+)/) do |match|
        name = match.shift
        break
      end
    end
    @cmd.processed
    name
  end

  def target(unicast_address)
    request = "target %04x" % [unicast_address]
    @cmd.new_command_without_response(request)
    @cmd.processed
  end

  def appkey_add(index)
    @cmd.new_command_without_response("appkey-add #{index}")
    @cmd.processed
  end

  def bind(ele_idx, app_idx, mod_id)
    request = "bind %d %d %4x" %[ele_idx, app_idx, mod_id]
    @cmd.new_command_without_response(request)
    @cmd.processed
  end

  def provision(uuid, ob_code)
    @cmd.new_command("provision #{uuid}")
    loop do
      line = @cmd.response_gets(2000)
      break unless line

      case line
      when /(Could\snot\sfind\sdevice\sproxy)/
        break
      when /Enter\sNumeric\skey:/
        next_step = true
        break
      end
    end

    @cmd.processed
    return nil unless next_step

    @cmd.new_command("%4d" % [ob_code])

    loop do
      line = @cmd.response_gets(2000)
      break unless line

      case line
      when /Composition\sdata\sfor\snode\s([A-Fa-f0-9]{4})\{/
        address = $1.to_i(16)
        json_capturing = true
        device_info = "{"
      when /^\}$/
        device_info += "}"
        json_capturing = false
        break
      else
        device_info += line if json_capturing
      end
    end

    @cmd.processed
    return nil unless address

    response = { unicast_address: address, device_info: device_info }
    [response.to_json]
  end

  def pub_set(ele_addr, pub_addr, app_idx, mod_id)
    request = "pub-set %4x %4x %d %4x" % [ele_addr, pub_addr, app_idx, mod_id]
    @cmd.new_command(request)
    result = false
    loop do
      line = @cmd.response_gets(2000)
      break unless line

      case line
      when /Node\s[A-Fa-f0-9]{4}\sPublication\sstatus\sSuccess/
        result = true
        break
      end
    end
    @cmd.processed
    result
  end

  def sub_add(ele_addr, sub_addr, mod_id)
    request = "sub-add %4x %4x %4x" % [ele_addr, sub_addr, mod_id]
    @cmd.new_command(request)

    result = false
    loop do
      line = @cmd.response_gets(2000)
      break unless line

      case line
      when /Node\s[A-Fa-f0-9]{4}\sSubscription\sstatus\sSuccess/
        result = true;
        break
      end
    end

    @cmd.processed
    result
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