require "nokogiri"

class ModsArticle

  attr_accessor :text, :xml

  def parse xml_record
    @xml = Nokogiri::XML(xml_record).remove_namespaces!
    @text = @xml.xpath("//note[@type='content']").text
  end
end
