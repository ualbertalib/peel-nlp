require_relative "./spec_helper"

include E

describe ModsArticle do

  before(:each) do
    mods_article_xml = File.open(E::*("fixtures/clean_mods_article.xml"))
    @mods_article = ModsArticle.new
    @mods_article.parse(mods_article_xml)
  end

  it "should parse an XML record" do
    expect(@mods_article.xml.to_xml).to include "<title>Eye Openers</title>"
  end

  it "should extract a full text field" do
    expect(@mods_article.text).to be_an_instance_of String
    expect(@mods_article.text).to include("Here is a bunch of text")
  end
end
