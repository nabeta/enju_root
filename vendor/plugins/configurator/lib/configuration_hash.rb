class ConfigurationHash < ActiveRecord::Base
  set_table_name 'config'
  
  belongs_to :associated, :polymorphic => true
  
  class << self
    
    def find_by_key_and_owner(call_type, key, owner, namespace = nil)
      options = namespace ? { :namespace => namespace } : {}
      find(:first, :conditions => { :key => key, 
                                    :associated_id => call_type == :instance ? owner.id : nil, 
                                    :associated_type => call_type == :instance ? owner.class.name : owner.name
                                   }.merge(options))
    end
    
    def find_all_by_owner(call_type, owner, namespace = nil)
      options = namespace ? { :namespace => namespace } : {}
      find(:all, :conditions => { :associated_id => call_type == :instance ? owner.id : nil, 
                                  :associated_type => call_type == :instance ? owner.class.name : owner.name 
                                  }.merge(options))
    end
    
  end
  
  def value=(param)
    write_attribute :value, param.to_s
    if respond_to?(:data_type)
      type = case param
      when TrueClass, FalseClass    : 'bool'
      when Float                    : 'float'
      when Integer, Fixnum          : 'integer'
      else 'string'
      end
      write_attribute :data_type, type
    end
  end
  
  def value
    return value_without_datatype unless respond_to?(:data_type)
    case data_type
    when 'bool'     : self[:value] == 'true'
    when 'float'    : self[:value].to_f
    when 'integer'  : self[:value].to_i
    else self[:value]
    end
  end
  
  def value_without_datatype
    ActiveSupport::Deprecation.warn("Add a data_type column to your Configurator table to store object types",caller)
    if key.ends_with? "?"
      read_attribute(:value) == "true"
    else
      read_attribute(:value)
    end
  end
  
end