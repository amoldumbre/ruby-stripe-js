json.extract! invoice, :id, :amount, :description, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
