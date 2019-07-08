#!/usr/bin/env ruby

require "socket"
require "dbus"
require "../lib/command.rb"
require "../lib/provisioner.rb"
require "../lib/bus_service.rb"


bus = DBus.system_bus
service = bus.request_service("org.embest")

server = TCPSocket.new("127.0.0.1", 5678)
cmd = Command.new(server)
$prov = Provisioner.new(cmd)

$dbus_object_on_off_server = GenericOnOffServerDbusObject.new(GenericOnOffServerDbusObject::ObjectPath)
$dbus_object_provisioner_server = ProvisionerDbusObject.new(ProvisionerDbusObject::ObjectPath)

service.export($dbus_object_on_off_server)
service.export($dbus_object_provisioner_server)

$prov.discover_unprovisioned(20)

Thread.new do

  loop {
    puts "Press any key to send UnprovisionedDeviceDiscovered signal..."
    gets
    $dbus_object_provisioner_server.UnprovisionedDeviceDiscovered("dd020000000000000000000000000000", "Light")

    puts "Dbus signal sent - new device discovered: Light(dd020000000000000000000000000000)"

   }
end

loop = DBus::Main.new
loop << bus
loop.run


