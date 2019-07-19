require "dbus"

bus = DBus::SystemBus.instance

ruby_service = bus.service("org.embest")
prov_obj = ruby_service.object("/org/embest/Provisioner")
prov_obj.introspect
prov_obj.default_iface = "org.embest.MeshInterface"

puts "Dbus connected."

# obj.DiscoverUnprovisioned(60)

prov_obj.on_signal("UnprovisionedDeviceDiscovered") do |uuid, name|
  puts "Discover new device: #{name}(#{uuid})"
end

def prov_dbus_method_test(dbus_obj, cmd_msg)
  args = cmd_msg.split(' ')
  cmd = args.shift.to_sym

  case cmd
  when :DiscoverUnprovisioned
    period = args[0].to_i
    dbus_obj.send cmd, period
    puts "Start scan..."
  when :DeviceName
    uuid = args[0]
    name = dbus_obj.send cmd, uuid
    puts "#{name}"
  when :Provision
    uuid = args[0]
    obcode = args[1].to_i
    json = dbus_obj.send cmd, uuid, obcode
    puts json
  when :Config
    address = args[0].to_i
    dbus_obj.send cmd, address
    puts "Now you can config the node %4x" % [address]
  when ModelName
    id = args[0].to_i
    model_name = dbus_obj.send cmd, id
    puts "#{model_name}"
  when :AppKeyAdd
    idx = args[0].to_i
    dbus_obj.send cmd, idx
    puts "App key added"
  when :Bind
    ele_idx = args[0].to_i
    app_idx = args[1].to_i
    mod_id = args[2].to_i
    dbus_obj send cmd, ele_idx, app_idx, mod_id
    puts "Done"
  when :PubSet
    ele_addr = args[0].to_i
    pub_addr = args[1].to_i
    app_idx = args[2].to_i
    mod_id = args[3].to_i
    dbus_obj send cmd, ele_addr, pub_addr, app_idx, mod_id
    puts "Done"
  when :SubAdd
    ele_addr = args[0].to_i
    sub_addr = args[1].to_i
    mod_id = args[2].to_i
    dbus_obj send cmd, ele_addr, sub_addr, mod_id
    puts "Done"
  else
    puts "Not support"
  end
end

loop {
  puts "Type provision dbus command to send"
  msg = gets
  prov_dbus_method_test(prov_obj, msg)
 }

loop = DBus::Main.new
loop << bus
loop.run