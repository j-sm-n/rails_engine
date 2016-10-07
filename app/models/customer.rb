class Customer < ApplicationRecord
  has_many :invoices
  has_many :transactions, through: :invoices
  has_many :merchants, through: :invoices

  def favorite_merchants
    merchants.joins(:transactions)
             .merge(Transaction.successful)
             .group(:id)
             .order("transactions.count DESC")
  end

  def favorite_merchant
    favorite_merchants.take
  end
end
