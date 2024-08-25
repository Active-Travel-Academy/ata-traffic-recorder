# https://github.com/heartcombo/simple_form/issues/1668#issuecomment-1756665238
class EnumInput < SimpleForm::Inputs::CollectionSelectInput
  def initialize(builder, attribute_name, column, input_type, options = {})
    raise ArgumentError, "EnumInput requires an enum column." unless column.is_a? ActiveRecord::Enum::EnumType

    super
  end

  def collection
    @collection ||= begin
                      raise ArgumentError,
                        "Collections are inferred when using the enum input, custom collections are not allowed." if options.key?(:collection)

                      object.defined_enums[attribute_name.to_s].keys.map do |key|
                        [key.to_s.capitalize.humanize, key]
                      end
                    end
  end
end
