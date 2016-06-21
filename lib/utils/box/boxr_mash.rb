class BoxrMash
  def client
    @client ||= Utils::Box::Client.instance
  end

  def details
    client.folder(self)
  end

  def folders
    client.folder_items(self).select do |entry|
      entry.type == 'folder'
    end
  end

  def items
    client.folder_items(self)
  end

  def files
    client.folder_items(self).select do |entry|
      entry.type == 'file'
    end
  end

  def create_folder(name)
    client.create_folder(name , self) #returns details of folder
  end

  def path
    paths = get_details(:path_collection).entries.map do |entry|
      entry.name
    end
    ["", paths, self.name].join('/')
  end

  private

  def get_details(attribute)
    self.send(attribute) || self.details.send(attribute)
  end
  
end
