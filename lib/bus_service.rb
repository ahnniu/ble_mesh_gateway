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
      ["XiaoMi Smart Light"]
    end

    # @!method Provision(uuid)
    # Provision a new device that discovered recently
    # @param uuid [String] the device's uuid
    # @return [String] a JSON string including the unicast_address and device_info
    dbus_method :Provision, "in uuid:s, out info:s" do |uuid|
      unicast_address = "0010"
      device_info = <<-EOF
        {
          "cid":"05f1",
          "pid":"0000",
          "vid":"0000",
          "crpl":"000a",
          "features":{
            "relay":true,
            "proxy":true,
            "friend":false,
            "lpn":false
          },
          "elements":[
            {
              "elementIndex":0,
              "location":"0000",
              "models":[
                "0000",
                "1000"
              ]
            }
          ]
        }
      EOF
      response = { unicast_address: unicast_address, device_info: device_info }
      [response.to_json]
    end
    
    # @!method Config(node_address)
    # Start to config the new provisioned device
    # @param node_address [Integer] the unicast address(unsigned short) of the node device
    dbus_method :Config, "in node_address:u, out error:s" do |node_address|
      [""]
    end

    # @!method ModelName(mod_id)
    # Get the SIG model name from an id
    # @param mod_id [Integer] the id(unsigned short) of a SIG model
    dbus_method :ModelName, "in mod_id:u, out name:s" do |mod_id|
      ["GenericOnOffServer"]
    end
    
    # @!method AppKeyAdd(idx)
    # Add an app key to the configuring node
    # @param idx [Integer] the index of the app key, this should be always 1
    # @return error [String] the error message, void message indicate that their
    # is no error
    dbus_method :AppKeyAdd, "in idx:i, out error:s" do |idx|
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
      [""]
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
      [""]
    end

    # @!method MeshInfo
    # Get the mesh network info. Usually, it should be called when the dbus client program
    # restart, it should reload the mesh network data again to sync.
    # @return info [String] a JSON string of the mesh data, others maybe the error message
    dbus_method :MeshInfo, "out info:s" do
      response = <<-EOF
        {
          "$schema":"file:\/\/\/BlueZ\/Mesh\/schema\/mesh.jsonschema",
          "meshName":"BT Mesh",
          "netKeys":[
            {
              "index":0,
              "keyRefresh":0,
              "key":"18eed9c2a56add85049ffc3c59ad0e12"
            }
          ],
          "appKeys":[
            {
              "index":0,
              "boundNetKey":0,
              "key":"4f68ad85d9f48ac8589df665b6b49b8a"
            },
            {
              "index":1,
              "boundNetKey":0,
              "key":"2aa2a6ded5a0798ceab5787ca3ae39fc"
            }
          ],
          "provisioners":[
            {
              "provisionerName":"BT Mesh Provisioner",
              "unicastAddress":"0077",
              "allocatedUnicastRange":[
                {
                  "lowAddress":"0100",
                  "highAddress":"7fff"
                }
              ]
            }
          ],
          "nodes":[
            {
              "deviceKey":"37fef1f4ce72e6028c29dae98a1c721e",
              "configuration":{
                "netKeys":[
                  "0000"
                ],
                "elements":[
                  {
                    "elementIndex":0,
                    "unicastAddress":"0100",
                    "models":[
                      {
                        "modelId":"1000",
                        "publish":{
                          "address":"0c00",
                          "index":"0001",
                          "ttl":255
                        },
                        "bind":[
                          1
                        ],
                        "subscribe":[
                          "ceef"
                        ]
                      }
                    ]
                  }
                ],
                "appKeys":[
                  "0001"
                ]
              },
              "composition":{
                "cid":"05f1",
                "pid":"0000",
                "vid":"0000",
                "crpl":"000a",
                "features":{
                  "relay":true,
                  "proxy":true,
                  "friend":false,
                  "lpn":false
                },
                "elements":[
                  {
                    "elementIndex":0,
                    "location":"0000",
                    "models":[
                      "0000",
                      "1000"
                    ]
                  }
                ]
              },
              "IVindex":5,
              "sequenceNumber":11
            }
          ],
          "IVindex":5,
          "IVupdate":0
        }
      EOF

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