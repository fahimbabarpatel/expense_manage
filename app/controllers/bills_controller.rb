class BillsController < ApplicationController

  def new
  	@bill = Bill.new
  end

  def create
  	@bill = Bill.new bill_params
  	if @bill.save
  	  if params[:bill_payer][:user_id].present?
  	  	params[:bill_payer][:user_id].keys.each do |u_id|
  	  	  @bill.bill_payers.create(user_id: u_id, amount: params[:bill_payer][:amount]["#{u_id}"].present? ? params[:bill_payer][:amount]["#{u_id}"] : 0)  	
  	  	end

        #credit logic
        # equal amount = divide total bill amount by number of attendees
        # if user had paid extra amount then other will paid him.
          credit_bal = {}
          equal_amount_to_paid = (params[:bill][:total_amount].to_f / @bill.bill_payers.count).round(2)
          
          @bill.bill_payers.order("amount desc").each do | billp|
            
            if billp.amount > equal_amount_to_paid
              
              extra_amount_paid = (billp.amount - equal_amount_to_paid).round(2)
              @bill.bill_payers.order("amount").each do | billc|
                
                if extra_amount_paid  != 0 
                  
                  if billc.user_id != billp.user_id
                    
                    if (credit_bal[billc.user_id].present? ? (credit_bal[billc.user_id] + billc.amount) : billc.amount) < equal_amount_to_paid
                       
                      amount_paid = (credit_bal[billc.user_id].present? ? (credit_bal[billc.user_id] + billc.amount) : billc.amount)

                       amount_to_paid = (equal_amount_to_paid - amount_paid).round(2)
                       if amount_to_paid < extra_amount_paid
                         extra_amount_paid = extra_amount_paid - amount_to_paid
                         credit_bal[billc.user_id].present? ? (credit_bal[billc.user_id] += amount_to_paid) : (credit_bal[billc.user_id] = amount_to_paid)
                         Credit.create to: billp.user_id, from: billc.user_id, amount: amount_to_paid, bill_id: @bill.id
                       else
                         Credit.create to: billp.user_id, from: billc.user_id, amount: extra_amount_paid, bill_id: @bill.id
                         credit_bal[billc.user_id].present? ? (credit_bal[billc.user_id] += extra_amount_paid) : (credit_bal[billc.user_id] = extra_amount_paid)
                         extra_amount_paid =  0
                         
                         
                       end

                    end 
                  
                  end
                
                end

              end

            end

          end
        # 
  	  end	
  	  redirect_to bills_path
  	else
  	  render :new
  	end	
  end

  def index
  	@users = User.all
  end


  private
  def bill_params
  	params.require(:bill).permit!
  end	
end
