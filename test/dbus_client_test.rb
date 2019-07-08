require "dbus"

bus = DBus::SystemBus.instance

ruby_service = bus.service("org.embest")
obj = ruby_service.object("/org/embest/Provisioner")
obj.introspect
obj.default_iface = "org.embest.MeshInterface"

puts "Dbus connected."

# obj.DiscoverUnprovisioned(60)

obj.on_signal("UnprovisionedDeviceDiscovered") do |uuid, name|
  puts "Discover new device: #{name}(#{uuid})"
end

Thread.new(obj) do |dbus_obj|

  loop {
    puts "Type dbus command to send"
    msg = gets
    args = msg.split(' ')
    cmd = args.shift

    dbus_obj.send cmd, args
    # $dbus_object_provisioner_server.UnprovisionedDeviceDiscovered("dd020000000000000000000000000000", "Light")

    puts "Dbus signal sent - #{msg}"

   }
end

loop = DBus::Main.new
loop << bus
loop.run