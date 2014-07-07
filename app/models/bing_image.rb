# a class to deal with bing image search results
# result data example:
# {:ID=>"a29aa807-a4e3-48f9-b9ce-ab064b6ad070",
# :Title=>"xbox one back side",
# :MediaUrl=>"http://thejetlife.com/wp-content/uploads/2013/05/xbox_one_8.jpg",
# :SourceUrl=>"http://thejetlife.com/2013/05/26/official-xbox-one-update/",
# :DisplayUrl=>"thejetlife.com/2013/05/26/official-xbox-one-update",
# :Width=>"1280",
# :Height=>"720",
# :FileSize=>"265097",
# :ContentType=>"image/jpeg",
# :Thumbnail=>
#  {:__metadata=>{:type=>"Bing.Thumbnail"},
#   :MediaUrl=>"http://ts4.mm.bing.net/th?id=HN.607999882784866695&pid=15.1",
#   :ContentType=>"image/jpg",
#   :Width=>"480",
#   :Height=>"270",
#   :FileSize=>"15501"}}
class BingImage
  attr_accessor :url, :width, :height, :thumbnail, :thumbnail_width,
                :thumbnail_height

  def initialize(data)
    self.url = data[:MediaUrl]
    self.width = data[:Width]
    self.height = data[:Height]

    return if data[:Thumbnail].blank?
    self.thumbnail = data[:Thumbnail][:MediaUrl]
    self.thumbnail_width = data[:Thumbnail][:Width]
    self.thumbnail_height = data[:Thumbnail][:Height]
  end
end
