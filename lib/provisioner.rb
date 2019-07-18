#!/usr/bin/env ruby

require 'json'
require "../lib/group_address"
require '../lib/model'
require '../lib/generic_on_off'

class Provisioner
  attr_reader :address

  def initialize(command)
    @cmd = command

    @models = []
    @address = 0

    reload_mesh
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
        case line
        when /No\sdefault\scontroller\savailable/
          error_msg = "No default controller available"
          break
        when /Device\s+UUID:\s+([0-9A-Fa-f]{32})/
          # May have muti-devices been found
          uuid = $1
          $dbus_object_provisioner_server.UnprovisionedDeviceDiscovered(uuid, "")
        end

      end

      @cmd.processed
      $dbus_object_provisioner_server.Error(error_msg) if error_msg

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

      json_capturing = false
      case line
      when /Composition\sdata\sfor\snode\s([A-Fa-f0-9]{4})\{/
        address = $1.to_i(16)
        json_capturing = true
        device_info = "{\n"
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

    { unicast_address: address, device_info: JSON.parse(device_info) }
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

    if result
      model_pub_set(element_address, publish_address, model_id)
    end

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

  def mesh_info
    @cmd.new_command("mesh-info")

    json_begin = json_end = false
    loop do
      line = @cmd.response_gets(1000)
      break unless line

      case line
      when /\{/
        json_begin = true
        json = "{\n"
      when /\}/
        json_end = true
        json += "}"
        break
      else
        json += line if json_begin && !json_end
      end
    end

    @cmd.processed
    return nil unless json_end
    JSON.parse(json)
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

  public

  def reload_mesh
    json = mesh_info
    return nil unless json

    provisioner_settings = json["provisioners"][0]
    @address = provisioner_settings["unicastAddress"].to_i(16)

    nodes = json["nodes"]
    nodes.each do |node|
      elements = node["configuration"]["elements"]
      elements.each do |element|
        ele_idx = element["elementIndex"]
        ele_address = element["unicastAddress"]
        modes = elements["models"]
        modes.each do |model|
          mod_id = model["modelId"].to_i(16)
          publish_address = model["publish"]["address"].to_i(16)
          model_pub_set(ele_address, publish_address, mod_id)
        end
      end
    end

    json
  end

end