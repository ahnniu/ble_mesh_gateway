#!/usr/bin/env ruby

require "socket"
require '../lib/command.rb'
require '../lib/provisioner.rb'

server = TCPSocket.new("127.0.0.1", 5678)
cmd = Command.new(server)
prov = Provisioner.new(cmd)

prov.discover_unprovisioned(20)
puts "waiting ..."



loop {
  sleep 1
  puts "discovered: #{prov.devices_unprovisioned.to_s}"
}


