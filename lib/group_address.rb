
class GroupAddress

  @@groups = []

  def self.generate(name)
    address = 0xc000 + @addresses.length

    group[:name] = name
    group[:address] = address

    @@groups.push group

    address
  end

  def self.get_address(name)

  end

  def self.get_name(address)

  end

  def self.class_method_name

  end

end