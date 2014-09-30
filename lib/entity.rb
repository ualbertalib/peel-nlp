require "linkeddata"

class Entity

  attr_reader :name, :model

  def initialize(name, model)
    @name, @model = name, model
    @base_uri = "http://dbpedia.org/resource/"
  end

  def uri
    URI(@base_uri+@name.split.join("_"))
  end

  def valid?
    @validity || validate
  end

  def statements
    @statements || harvest_statements
  end

  def to_s
    "#{@name},#{@model},#{uri},#{valid?}"
  end

  private

  def harvest_statements
    @statements = []
    RDF::Graph.load(uri).statements.each do |statement|
      @statements << statement
    end
  end

  def validate
    open(uri){|f| valid f}
    rescue OpenURI::HTTPError => e
  end

  def valid f
    f.status.first == "200"
  end
end
