module Priced
  class ApplicationRecord < Priced.model_parent_class.constantize
    self.abstract_class = true
    self.table_name_prefix = "priced_"
  end
end
