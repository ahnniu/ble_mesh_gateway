#!/usr/bin/env ruby

require "socket"
require "dbus"
require "../lib/command.rb"
require "../lib/provisioner.rb"
require "../lib/bus_service.rb"


bus = DBus.system_bus
service = bus.request_service("org.embest")

server = TCPSocket.new("127.0.0.1", 4000)
cmd = Command.new(server)
$prov = Provisioner.new(cmd)

$dbus_object_on_off_server = GenericOnOffServerDbusObject.new(GenericOnOffServerDbusObject::ObjectPath)
$dbus_object_provisioner_server = ProvisionerDbusObject.new(ProvisionerDbusObject::ObjectPath)

service.export($dbus_object_on_off_server)
service.export($dbus_object_provisioner_server)

puts "Waiting dbus client to send commands..."

loop = DBus::Main.new
loop << bus
loop.run


