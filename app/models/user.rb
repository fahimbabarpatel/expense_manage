class User < ActiveRecord::Base
  has_many :bill_payers
end
