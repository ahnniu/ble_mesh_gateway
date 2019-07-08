require "dbus"

class ProvisionerDbusObject < DBus::Object
  ObjectPath = "/org/embest/Provisioner"

  dbus_interface "org.embest.MeshInterface" do

    dbus_method :DiscoverUnprovisioned, "in period:i" do |period|
      puts "Start to scan unprovisioned devices for #{period}..."
      $prov.discover_unprovisioned(period)
    end

    dbus_method :DeviceName, "in uuid, out name:s" do |uuid|
      ["#{name}"]
    end

    dbus_signal :UnprovisionedDeviceDiscovered, "uuid:s, name:s"
    dbus_signal :Error, "msg:s"
  end

end

class GenericOnOffServerDbusObject < DBus::Object
  ObjectPath = "/org/embest/GenericOnOffServer"

  dbus_interface "org.embest.MeshInterface" do
    dbus_signal :Publish, "address:u, state:b"
  end

end