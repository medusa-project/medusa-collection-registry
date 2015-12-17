#These serve two related but distinct purposes
#They help create the initial table and javascript when the navbar search box is used
#Then they help conduct the actual search when the datatables call back to get data
#For the first initialize with :initial_search_string
#For the second initialize with :params
#Note that for before generation we decorate the model - this allows us to hook in view code like link_to, *_path, etc.
#in a semi-reasonable way, but means you need to have a decorator for any model you're searching.
#Subclasses need to implement the indicated methods, and solr search in the models must be set up with
#the corresponding fields given in columns (See CfsFile subclass for an example). Given that this should
#make it pretty easy to add in all needed searches.
#In the columns the header is the header for the html/datatables table, the solr_field is the field on the model for
#the column, used when a sort is requested, and value_method is either a symbol, which is sent to the (decorated) object
#to get a table entry or a Proc that takes one argument (the object) to get a table entry. Unsortable indicates that the
#column should not be marked as sortable in datatables.
#Of course any of this stuff can be overriden as needed.
class SearchHelper::Base < Object

  attr_accessor :initial_search_string, :params

  def initialize(args = {})
    self.initial_search_string = args[:initial_search_string] || ''
    self.params = args[:params] || Hash.new
  end

  def table_id
    raise NotImplementedError, 'Subclass responsibility'
  end

  def url
    raise NotImplementedError, 'Subclass responsibility'
  end

  def headers
    columns.collect { |c| c[:header] }
  end

  def full_count
    raise NotImplementedError, 'Subclass responsibility'
  end

  def base_class
    raise NotImplementedError, 'Subclass responsibility'
  end

  def columns
    raise NotImplementedError, 'Subclass responsibility'
  end

  def draw
    params[:draw].to_i
  end

  def search_string
    params[:search][:value]
  end

  def per_page
    count = params[:length].to_i
    count > 0 ? count : full_count
  end

  def page
    1 + (params[:start].to_i / per_page)
  end

  def order_direction
    params[:order]['0']['dir'] rescue nil
  end

  def order_field
    column_index = params[:order]['0']['column'].to_i
    columns[column_index][:solr_field]
  rescue
    nil
  end

  def unsortable_columns
    columns.each.with_index.collect {|spec, index| [spec, index]}.select {|pair| pair.first[:unsortable]}.collect {|pair| pair.second}
  end

  def search
    raise NotImplementedError, 'Subclass responsibility'
  end

  def response
    {draw: draw,
     recordsTotal: full_count,
     recordsFiltered: search.total,
     data: search.results.collect { |result| row(result.decorate) }}
  end

  def row(decorated_object)
    value_methods.collect { |method| column_entry(method, decorated_object) }
  end

  def column_entry(method, decorated_object)
    case method
      when Symbol
        decorated_object.send(method)
      when Proc
        method.call(decorated_object)
      else
        raise RuntimeError, "Unrecognized method for search helper evaluation"
    end
  end


  def value_methods
    columns.collect { |c| c[:value_method] }
  end

  def json_response
    response.to_json
  end

  def search_fields
    columns.select { |c| c[:searchable] }.collect { |c| c[:solr_field] }
  end

  protected

  def base_name
    base_class.to_s.underscore
  end

  def base_plural_name
    base_name.pluralize
  end

end