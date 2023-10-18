# frozen_string_literal: true

require 'oj'

Blueprinter.configure do |config|
  config.generator         = Oj
  config.sort_fields_by    = :definition
end

module Blueprinter
  class Base
    def self.fields(*field_names, **options)
      field_names.each do |field_name|
        field(field_name, options)
      end
    end
  end
end
