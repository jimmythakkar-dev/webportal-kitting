=begin
Programmer: Santosh Kumar Mohanty
Date: Wed, 23 Apr 2014 12:45:31 +0530

Adding New methods to String Class
Method: to_boolean,numeric?,floating_number?,positive?,negative?

# Numbers...
1.to_boolean # => true
0.to_boolean # => false

# Numbers as strings...
'1'.to_boolean # => true
'0'.to_boolean # => false

# Truthy strings (case insensitive)...
'true'.to_boolean  # => true  (alias: 't')
'false'.to_boolean # => false (alias: 'f')
'yes'.to_boolean   # => false (alias: 'y')
'no'.to_boolean    # => false (alias: 'n')

# Booleans...
true.to_boolean  # => true
false.to_boolean # => false

# Nil...
nil.to_boolean # => false

"42".numeric? #=> true
"-42".numeric? #=> true
"1.2".floating_number? #=> true
"0".numeric? #=> true
"1.2e34".floating_number? #=> true
"1_000".floating_number? #=> true
"".numeric? #=> false
" ".numeric? #=> false
"a".numeric? #=> false
"-".numeric? #=> false
".".numeric? #=> false
"_".numeric? #=> false
"1.2.3".numeric? #=> false

4.positive? #=> true
0.positive? #=> true
-3.positive? #=> false
3.negative? #=> true

=end
class String

  def to_boolean
    return true if self == true || self =~ (/^(true|yes|1)$/i)
    return false if self == false || self.blank? || self =~ (/^(false|no|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end

  def numeric?
    Integer(self) != nil rescue false
  end

  def floating_number?
    Float(self) != nil rescue false
  end

end

class Fixnum

  def to_boolean
    return true if self == 1
    return false if self == 0
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end

  def positive?
    self >= 0
  end

  def negative?
    self < 0
  end

end

class NilClass
  def to_boolean; false; end
end

# Writing New Methods for Hash Class

# pick method to pick records from array depending upon keys
class Hash
  def pick(*keys)
    Hash[select { |k, v| keys.include?(k) }]
  end
end
