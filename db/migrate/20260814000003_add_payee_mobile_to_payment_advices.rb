class AddPayeeMobileToPaymentAdvices < ActiveRecord::Migration[8.1]
  def change
    add_column :payment_advices, :payee_mobile, :string
  end
end
