class RemovePayeeMobileFromPaymentAdvices < ActiveRecord::Migration[8.1]
  def change
    remove_column :payment_advices, :payee_mobile, :string
  end
end
