class <%= Thor::Util.camel_case(name) %>
<%= "\n  # #{description}\n" if description.present? %>
  def self.run
    #TODO: data_migration code
  end
end
