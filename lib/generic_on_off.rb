class GenericOnOffServer < Model
  def initialize()

    @elements = []
  end

  def id
    0x1000
  end

  def process_message(source, dest, opcode, data)
    case opcode
    when 0x8204
      state = data[0] == 0 ? false : true
      $dbus_object_on_off_server.Publish(dest, state)
    end
  end

  def pub_set(element_address, address)
    @elements.each do |element|
      if element[:element_address] == element_address
        element[:publish_address] = address
        return
      end
    end
    element = { element_address: element_address, publish_address: address, state: 0 }
    @elements.push element
  end

end


class GenericOnOffClient < Model
  attr_reader :elements

  def initialize()
    @elements = []
    @trans_id = 0
  end

  def id
    0x1001
  end

  def pub_set(element_address, address)
    @elements.each do |element|
      if element[:element_address] == element_address
        element[:address] = address
        return
      end
    end
    element = { element_address: element_address, publish_address: address }
    @elements.push element
  end

  def on(address)

  end

  def off(address)

  end


end