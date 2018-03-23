=begin
Programmer: Reena Mary
Date: Wed, 29 Oct 2014 12:45:31 +0530

Adding New methods to Array Class
Method: to_boolean

=end

class Array
  def division_sort
    result = {}

    self.each do |value|
      denominator = value.split('/')[1].to_i
      result[denominator] = [] unless result.has_key? denominator
      result[denominator] << value
    end
    new_value = Hash[result.sort_by{|k,v| k}].values.flatten
    result = {}
    new_value.each do |value|
      numerator = value.split('/')[0].to_i
      result[numerator] = [] unless result.has_key? numerator
      result[numerator] << value
    end
    new_value = Hash[result.sort_by{|k,v| k}].values.flatten
  end
end