Factory.define :content_type do |f|
  f.sequence(:name){|n| "content_type_#{n}"}
end
