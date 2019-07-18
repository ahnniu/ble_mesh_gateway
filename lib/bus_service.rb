require "dbus"
require "json"

class ProvisionerDbusObject < DBus::Object
  ObjectPath = "/org/embest/Provisioner"

  dbus_interface "org.embest.MeshInterface" do

    # @!method DiscoverUnprovisioned(period)
    # To scan or discover new unprovisoned devices
    # @param period [Numeric] the period in second to scan
    dbus_method :DiscoverUnprovisioned, "in period:i" do |period|
      puts "Start to scan unprovisioned devices for #{period}..."
      $prov.discover_unprovisioned(period)
    end

    # @!method DeviceName(uuid)
    # Get an unprovisioned device name by it's uuid
    # @param uuid [String] the device's uuid
    # @return [String] the name of the device
    dbus_method :DeviceName, "in uuid:s, out name:s" do |uuid|
      name = @prov.info_dev(uuid)
      [name]
    end

    # @!method Provision(uuid)
    # Provision a new device that discovered recently
    # @param uuid [String] the device's uuid
    # @param obcode [Integer] the device's obcode
    # @return [String] a JSON string including the unicast_address and device_info
    dbus_method :Provision, "in uuid:s, in obcode:i, out info:s" do |uuid, obcode|
      response = $prov.provision(uuid, obcode)
      response = { unicast_address: 0, device_info: ""} unless response
      [response.to_json]
    end

    # @!method Config(node_address)
    # Start to config the new provisioned device
    # @param node_address [Integer] the unicast address(unsigned short) of the node device
    dbus_method :Config, "in node_address:u, out error:s" do |node_address|
      $prov.target(node_address)
      [""]
    end

    # @!method ModelName(mod_id)
    # Get the SIG model name from an id
    # @param mod_id [Integer] the id(unsigned short) of a SIG model
    dbus_method :ModelName, "in mod_id:u, out name:s" do |mod_id|
      name = Model.get_model_class_name(mod_id)
      [name]
    end

    # @!method AppKeyAdd(idx)
    # Add an app key to the configuring node
    # @param idx [Integer] the index of the app key, this should be always 1
    # @return error [String] the error message, void message indicate that their
    # is no error
    dbus_method :AppKeyAdd, "in idx:i, out error:s" do |idx|
      $prov.appkey_add(idx)
      [""]
    end

    # @!method Bind(ele_idx, app_idx, mod_id)
    # Bind an app key to a model on the element
    # @param ele_idx [Integer] the element index of the configuring node
    # @param app_idx [Integer] the index of app key to bind
    # @param mod_id [Integer] the SIG model id in the element
    # @return error [String] the error message, void message indicate that their
    # is no error
    dbus_method :Bind, "in ele_idx:i, in app_idx:i, in mod_id:u, out error:s" do |ele_idx, app_idx, mod_id|
      $prov.bind(ele_idx, app_idx, mod_id)
      [""]
    end

    # @!method PubSet(ele_addr, pub_addr, app_idx, mod_id)
    # Set publish. For example, An OnOff Server(usually a light) can publish its onoff status
    # to a group address, who watch/subscribe the group address can get its status periodly.
    # An OnOff client(usually a switch) can publish a onoff command to a group address.
    # other models who watch /subscribe the group address, can response the command to
    # turn on or off
    # @param ele_addr [Integer] the unicast address of the element
    # @param pub_addr [Integer] the group address that to publish to
    # @param app_idx [Integer] the index of app key. Currently, it can always be 1
    # @param mod_id [Integer] the SIG model id in the element
    # @return error [String] the error message, void message indicate that their
    # is no error
    dbus_method :PubSet, "in ele_addr:u, in pub_addr:u, in app_idx:i, in mod_id:u, out error:s" do |ele_addr, pub_addr, app_idx, mod_id|
      result = $prov.pub_set(ele_addr, pub_addr, app_idx, mod_id)
      if result
        error_msg = ""
      else
        error_msg = "Failed"
      end
      [error_msg]
    end

    # @!method SubAdd(ele_addr, sub_addr, mod_id)
    # Set subscibe. For example, An OnOff server(usually a light) can subscribe 2 group
    # address(switch, one is the switch to control the light only, the other is the switch
    # to control all the lights in the living room).
    # Usually, a client model do not need to set subscribe.
    # @param ele_addr [Integer] the unicast address of the element
    # @param  sub_addr [Integer] the group address that to subscribe from
    # @param mod_id [Integer] the SIG model id in the element
    # @return error [String] the error message, void message indicate that their
    # is no error
    dbus_method :SubAdd, "in ele_addr:u, in sub_addr:u, in mod_id:u, out error:s" do |ele_addr, sub_addr, mod_id|
      result = $prov.sub_add(ele_addr, sub_addr, mod_id)
      if result
        error_msg = ""
      else
        error_msg = "Failed"
      end
      [error_msg]
    end

    # @!method MeshInfo
    # Get the mesh network info. Usually, it should be called when the dbus client program
    # restart, it should reload the mesh network data again to sync.
    # @return info [String] a JSON string of the mesh data, others maybe the error message
    dbus_method :MeshInfo, "out info:s" do
      mesh_info = $prov.reload_mesh
      if mesh_info
        response = mesh_info.to_json
      else
        response = ""
      end
      [response]
    end

    # @!method UnprovisionedDeviceDiscovered(uuid, name)
    # A new device is discovered and signal to the dbus client
    # @param uuid [String] the uuid of the new device
    # @param name [String] the name of the new device, it always be a void string
    dbus_signal :UnprovisionedDeviceDiscovered, "uuid:s, name:s"

    # @!method Error(msg)
    # Errors when DiscoverUnprovisioned calling
    # @param msg [String] the error messge
    dbus_signal :Error, "msg:s"
  end

end

class GenericOnOffServerDbusObject < DBus::Object
  ObjectPath = "/org/embest/GenericOnOffServer"

  dbus_interface "org.embest.MeshInterface" do

    # @!method Publish(address, state)
    # For a Dbus client, it should capture the address to get a new on off state
    # @param address [Integer] the gourp address that an onoff server to publish to
    # @param state [Bool] the new on off state
    dbus_signal :Publish, "address:u, state:b"
  end

end

class GenericOnOffClientDbusObject < DBus::Object
  ObjectPath = "/org/embest/GenericOnOffClient"

  dbus_interface "org.embest.MeshInterface" do

    # @!method Set(address, state)
    # Publish an on off command to a group address(just like a swith, different
    # address means different switch)
    # @param address [Integer] the group address to publish message to
    # @param state [Bool] the new on off state to publish
    # @return error [String] the error messge
    dbus_method :Set, "in address:i, in state:i, out error:s" do |address, state|
      [""]
    end

    # @!method Get(address)
    # Publish an on off get command to a group address to get state
    # @param address [Integer] the group address to publish message to
    # return state [String] the state(0 / 1), void means error occurs
    dbus_method :Get, "in address:i, out state:s" do |address|
      ["1"]
    end
  end

end