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

    dbus_method :Provision, "in uuid, out info:s" do |uuid|
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
      [unicast_address, device_info]
    end

    dbus_method :AppKeyAdd, "in idx:i, out error:s" do |idx|
      [""]
    end

    dbus_method :Bind, "in ele_idx:i, in app_idx:i, in mod_id:u, out error:s" do |ele_idx, app_idx, mod_id|
      [""]
    end

    dbus_method :PubSet, "in ele_addr:u, in pub_addr:u, in app_idx:i, in mod_id:u, out error:s" do |ele_addr, pub_addr, app_idx, mod_id|
      [""]
    end

    dbus_method :SubAdd, "in ele_addr:u, in sub_addr:u, in mod_id:u, out error:s" do |ele_addr, sub_addr, mod_id|
      [""]
    end

    dbus_method :MeshInfo do
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

class GenericOnOffClientDbusObject < DBus::Object
  ObjectPath = "/org/embest/GenericOnOffClient"

  dbus_interface "org.embest.MeshInterface" do
    dbus_method :Set, "in address:i, in state:i, out error:s" do |address, state|
      [""]
    end

    dbus_method :Get, "in address:i, out state:s" do |address|
      ["1"]
    end
  end

end