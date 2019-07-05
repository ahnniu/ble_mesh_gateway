class Model
  @@SIG_MODELS = [
    { id: 0x1000, name: "GenericOnOffServer" },
    { id: 0x1001, name: "GenericOnOffClient" }
  ]

  def id
    0
  end

  def process_message(source, dest, opcode, data)

  end

  def sub_add(address)

  end

  def pub_set(element_address, address)

  end

  def self.get_model_class_name(model_id)
    name = nil
    @@SIG_MODELS.each do |model|
      if model_id == model[:id]
        name = model[:name]
        break
      end
    end

    name
  end
end