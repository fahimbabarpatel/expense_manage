module ApplicationHelper
  def total_events user
  	user.bill_payers.count rescue nil
  end	


  def total_amount user
  	amount = 0
  	if total_events(user) > 0
  	  user.bill_payers.each do |b|
  	    amount = amount + (b.amount.present? ? b.amount : 0)
  	  end  
  	end

  	return amount
  end

  def cal_credit user, users
    text = []
    users.each do |u|
      text << "#{user.name} need to pay #{credit_amount user, u} to #{u.name}" if u.id != user.id
    end  
    text
  end

  def credit_amount user, u
    Credit.where(from: user.id, to: u.id).sum(:amount)
  end

end
