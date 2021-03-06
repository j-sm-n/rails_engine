require 'rails_helper'

describe "Invoices CRUD API" do
  it "returns a list of invoices" do
    create_list(:invoice, 3)
    get '/api/v1/invoices.json'

    invoices = JSON.parse(response.body)

    expect(response).to be_success
    expect(invoices.count).to eq(3)
  end

  it "returns a single invoice" do
    invoice = create(:invoice, status: "shipped")
    get "/api/v1/invoices/#{invoice.id}.json"

    raw_invoice = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_invoice["status"]).to eq("shipped")
  end

  it "returns a random invoice" do
    create(:invoice, status: "pending")
    create(:invoice, status: "shipped")
    create(:invoice, status: "returned")
    get '/api/v1/invoices/random.json'

    random_invoice = JSON.parse(response.body)

    expect(response).to be_success
    expect(['pending', 'shipped', 'returned']).
    to include(random_invoice["status"])
  end

  it "finds a single invoice by id" do
    invoice = create(:invoice, status: "shipped")
    get "/api/v1/invoices/find?id=#{invoice.id}"

    raw_invoice = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_invoice["id"]).to eq(invoice.id)
    expect(raw_invoice["status"]).to eq("shipped")
  end

  it "finds a single invoice by merchant id" do
    merchant = create(:merchant)
    invoice  = create(:invoice, merchant: merchant)
    get "/api/v1/invoices/find?merchant_id=#{merchant.id}"

    raw_invoice = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_invoice["id"]).to eq(invoice.id)
    expect(raw_invoice["merchant_id"]).to eq(merchant.id)
  end

  it "finds a single invoice by customer id" do
    customer = create(:customer)
    invoice  = create(:invoice, customer: customer)
    get "/api/v1/invoices/find?customer_id=#{customer.id}"

    raw_invoice = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_invoice["id"]).to eq(invoice.id)
    expect(raw_invoice["customer_id"]).to eq(customer.id)
  end

  it "finds a single invoice by status" do
    invoice  = create(:invoice, status: "shipped")
    get "/api/v1/invoices/find?status=#{invoice.status}"

    raw_invoice = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_invoice["id"]).to eq(invoice.id)
    expect(raw_invoice["status"]).to eq("shipped")
  end

  it "finds all invoices by id" do
    invoice = create(:invoice)
              create_list(:invoice, 2)
    get "/api/v1/invoices/find_all?id=#{invoice.id}"

    raw_invoice = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_invoice).to be_an(Array)
    expect(raw_invoice[0]["id"]).to eq(invoice.id)
  end

  it "finds all invoices by merchant id" do
    merchant = create(:merchant)
               create(:invoice, merchant: merchant)
               create(:invoice, merchant: merchant)
               create(:invoice)
    get "/api/v1/invoices/find_all?merchant_id=#{merchant.id}"

    raw_invoices = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_invoices).to be_an(Array)
    expect(raw_invoices.count).to eq(2)
    expect(raw_invoices[0]["merchant_id"]).to eq(merchant.id)
  end

  it "finds all invoices by customer id" do
    customer = create(:customer)
               create(:invoice, customer: customer)
               create(:invoice, customer: customer)
               create(:invoice)
    get "/api/v1/invoices/find_all?customer_id=#{customer.id}"

    raw_invoices = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_invoices).to be_an(Array)
    expect(raw_invoices.count).to eq(2)
    expect(raw_invoices[0]["customer_id"]).to eq(customer.id)
  end

  it "finds all invoices by status" do
    create(:invoice, status: "pending")
    create(:invoice, status: "pending")
    create(:invoice)
    get "/api/v1/invoices/find_all?status=pending"

    raw_invoices = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_invoices).to be_an(Array)
    expect(raw_invoices.count).to eq(2)
    expect(raw_invoices[0]["status"]).to eq("pending")
  end

  it 'omits timestamp data from json response' do
    invoices = create_list(:invoice, 3)
    get '/api/v1/invoices.json'
    res = JSON.parse(response.body)
    expect(response).to be_success
    expect(res.count).to eq(3)
    expect(res.first.keys).to eq(['id', 'customer_id', 'merchant_id', 'status'])
  end

  it 'finds a single invoice by created at' do
    inv1 = create(:invoice, status: 'success', created_at: "2012-03-27T14:54:05.000Z")
    inv2 = create(:invoice, status: 'failed', created_at: "2012-03-28T14:54:05.000Z")
    inv3 = create(:invoice, status: 'success', created_at: "2012-03-29T14:54:05.000Z")
    get "/api/v1/invoices/find?created_at=#{inv2.created_at}"
    res = JSON.parse(response.body)
    expect(response).to be_success
    expect(res['status']).to eq('failed')
  end

  it 'finds a single invoice by updated at' do
    inv1 = create(:invoice, status: 'success', updated_at: "2012-03-27T14:54:05.000Z")
    inv2 = create(:invoice, status: 'failed', updated_at: "2012-03-28T14:54:05.000Z")
    inv3 = create(:invoice, status: 'success', updated_at: "2012-03-29T14:54:05.000Z")
    get "/api/v1/invoices/find?updated_at=#{inv2.updated_at}"
    res = JSON.parse(response.body)
    expect(response).to be_success
    expect(res['status']).to eq('failed')
  end

  it 'finds all invoices by created at' do
    inv1 = create(:invoice, status: 'success', created_at: "2012-03-27T14:54:05.000Z")
    inv2 = create(:invoice, status: 'failed', created_at: "2012-03-28T14:54:05.000Z")
    inv3 = create(:invoice, status: 'success', created_at: "2012-03-27T14:54:05.000Z")
    get "/api/v1/invoices/find_all?created_at=2012-03-27T14:54:05.000Z"
    res = JSON.parse(response.body)
    expect(response).to be_success
    expect(res.count).to eq(2)
    expect(res.first['status']).to eq("success")
    expect(res.last['status']).to eq("success")
  end

  it 'finds all invoices by updated at' do
    inv1 = create(:invoice, status: 'success', updated_at: "2012-03-27T14:54:05.000Z")
    inv2 = create(:invoice, status: 'failed', updated_at: "2012-03-28T14:54:05.000Z")
    inv3 = create(:invoice, status: 'success', updated_at: "2012-03-27T14:54:05.000Z")
    get "/api/v1/invoices/find_all?updated_at=2012-03-27T14:54:05.000Z"
    res = JSON.parse(response.body)
    expect(response).to be_success
    expect(res.count).to eq(2)
    expect(res.first['status']).to eq("success")
    expect(res.last['status']).to eq("success")
  end
end

describe "Invoices Relationships" do
  it 'returns a list of transactions for the invoice' do
    invoice = create(:invoice)
              create(:transaction, invoice: invoice, result: 'failed')
              create(:transaction, invoice: invoice, result: 'failed')
              create(:transaction, invoice: invoice, result: 'success')
    get "/api/v1/invoices/#{invoice.id}/transactions"
    raw_transactions = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_transactions.count).to eq(3)
    expect(raw_transactions.first['result']).to eq('failed')
    expect(raw_transactions.last['result']).to eq('success')
    expect(raw_transactions.first['invoice_id']).to eq(invoice.id)
  end

  it 'returns a list of invoice items for the invoice' do
    invoice = create(:invoice)
              create(:invoice_item, invoice: invoice, quantity: 3)
              create(:invoice_item, invoice: invoice, quantity: 4)
              create(:invoice_item, invoice: invoice, quantity: 5)
    get "/api/v1/invoices/#{invoice.id}/invoice_items"
    raw_invoice_items = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_invoice_items.count).to eq(3)
    expect(raw_invoice_items.first['quantity']).to eq(3)
    expect(raw_invoice_items.last['quantity']).to eq(5)
    expect(raw_invoice_items.first['invoice_id']).to eq(invoice.id)
  end

  it 'returns a list of items for the invoice' do
    invoice = create(:invoice)
    item1 = create(:item, name: "Apple" )
    item2 = create(:item, name: "Bandana" )
    item3 = create(:item, name: "Cookie" )
    create(:invoice_item, invoice: invoice, item: item1)
    create(:invoice_item, invoice: invoice, item: item2)
    create(:invoice_item, invoice: invoice, item: item3)

    get "/api/v1/invoices/#{invoice.id}/items"
    raw_items = JSON.parse(response.body)

    expect(response).to be_success
    expect(raw_items.count).to eq(3)
    expect(raw_items.first['name']).to eq('Apple')
    expect(raw_items.last['name']).to eq('Cookie')
  end

  it 'returns the customer for the invoice' do
    customer = create(:customer, first_name: "Jasmin")
    invoice = create(:invoice, customer: customer)
    get "/api/v1/invoices/#{invoice.id}/customer"
    raw_customer = JSON.parse(response.body)
    expect(response).to be_success
    expect(raw_customer['first_name']).to eq("Jasmin")
  end

  it 'returns the merchant for the invoice' do
    merchant = create(:merchant, name: "David")
    invoice = create(:invoice, merchant: merchant)
    get "/api/v1/invoices/#{invoice.id}/merchant"
    raw_merchant = JSON.parse(response.body)
    expect(response).to be_success
    expect(raw_merchant['name']).to eq("David")
  end
end
