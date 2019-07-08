require "dbus"

bus = DBus::SystemBus.instance

ruby_service = bus.service("org.embest")
obj = ruby_service.object("/org/embest/Provisioner")
obj.introspect
obj.default_iface = "org.embest.MeshInterface"

puts "Dbus connected, sending commands: DiscoverUnprovisioned 60"

obj.DiscoverUnprovisioned(60)

obj.on_signal("UnprovisionedDeviceDiscovered") do |uuid, name|
  puts "Discover new device: #{name}(#{uuid})"
end

loop = DBus::Main.new
loop << bus
loop.run