require "linkeddata"

class Entity

  attr_reader :name, :model

  def initialize(name, model)
    @name, @model = name, model
  end

  def uri
    URI("http://dbpedia.org/resource/"+@name.split.join("_"))
  end

  def valid?
    @validity || validate
  end

  def validate
    open(uri){|f| valid f}
    rescue OpenURI::HTTPError => e
  end

  def valid f
    f.status.first == "200"
  end

  def statements
    @statements || harvest_statements
  end

  def harvest_statements
    @statements = []
    RDF::Graph.load(uri).statements.each do |statement|
      @statements << statement
    end
  end

  def to_s
    "#{@name},#{@model},#{uri},#{valid?}"
  end
end
